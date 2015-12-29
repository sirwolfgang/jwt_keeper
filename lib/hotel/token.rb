# This module encapsulates the functionality
# for generating, retrieving, and validating an
# auth token
module Hotel

  class Token

    def initialize(config)
      @config = config
    end

    # Uses the TokenExpire
    # place the token in a
    # blacklist
    #
    # @param token
    # @return bool
    def invalidate(token)
      begin
        tok = decode_token(token)
      rescue JWT::DecodeError
        raise InvalidJwtError.invalid_token
      rescue JWT::ExpiredSignature
        raise InvalidJwtError.expired_token
      end

      Store.expire(token, invalidation_expiry_for_token(token))
    end

    # For given claims generates
    # an encoded JWT
    #
    # @param  user_claims
    # @return string
    def generate(user_claims)
      return false unless user_claims.is_a?(Hash)

      encode(user_claims)
    end

    # We need to refind the user and tokenize
    # them again so we get accurate information
    # if they updated any of the users info
    #
    # @param jwt
    # @return string
    def refresh(jwt)
      decoded = validate(jwt)

      invalidate(jwt)

      user_claims = Hash[decoded.to_a - defaul_claims.to_a]

      encode(user_claims)
    end

    # For the given encoded JWT
    # check to see if it is a valid token
    #
    # @raise []
    # @return [true]
    def validate(jwt)

      if Store.is_expired?(jwt)
        raise InvalidJwtError.invalid_token
      end

      begin
        token = decode(jwt)
      rescue JWT::DecodeError
        raise InvalidJwtError.invalid_token
      rescue JWT::ExpiredSignature
        raise InvalidJwtError.expired_token
      end

      if token['nbf'] > Time.now
        raise InvalidJwtError.early_token
      end

      if token['iss'] != @config.issuer
        raise InvalidJwtError.bad_issuer
      end

      if token['aud'] != @config.audience
        raise InvalidJwtError.lousy_audience
      end

      token
    end

    alias_method :invalidate_token, :invalidate
    alias_method :generate_token, :generate
    alias_method :refresh_token, :refresh
    alias_method :validate_token, :validate

    private

    def invalidation_expiry_for_token(token)
      date = DateTime.iso8601(token['exp'])
      expires = date - DateTime.now
      ((expires) * 24 * 60 * 60).to_i
    end

    def encode(claims)
      JWT.encode(payload(claims), secret, @config.hashing_method)
    end

    def decode(token)
      JWT.decode(token, secret).first
    end

    # Gets the jwt secret from the
    # application secrets
    def secret
      Rails.application.secrets[:jwt_secret]
    end

    # Given given the user claims produces a token object
    # to be issued
    #
    # @param user_claims
    # @return a hash ready to be jwt encoded
    def payload(user_claims)
      defaul_claims.merge(user_claims)
    end

    def defaul_claims
      expires = @config.expiry.from_now.iso8601
      now = DateTime.now.iso8601

      {
        :iss => @config.issuer,            # issuer
        :sub => subject,                   # subject
        :aud => @config.audience,          # audience
        :exp => expires,                   # expiration time
        :nbf => now,                       # not before
        :iat => now,                       # issued at
        :jti => SecureRandom.uuid          # JWT ID
      }
    end
  end
end
