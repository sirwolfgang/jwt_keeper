# This module encapsulates the functionality
# for generating, retrieving, and validating an
# auth token
module Hotel

  #  This is a token
  class Token

    # Our token
    #
    # @param Hotel::Configuration config
    # @param Hotel::Store store
    def initialize(config, store)
      @config = config
      @store = store
    end

    # Uses the TokenExpire
    # place the token in a
    # blacklist
    #
    # @param token
    # @return bool
    def invalidate(token)
      begin
        decode_token(token)
      rescue JWT::DecodeError
        raise InvalidJwtError.invalid_token
      rescue JWT::ExpiredSignature
        raise InvalidJwtError.expired_token
      end

      @store.expire(token, invalidation_expiry_for_token(token))
    end

    # For given claims generates
    # an encoded JWT
    #
    # @param  user_claims
    # @return string
    def generate(user_claims)
      user_claims = { sub: user_claims } if user_claims.is_a?(String)

      raise InvalidJwtError.new('No subject') if user_claims[:sub].nil?

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
    # @param jwt
    # @raise InvalidJwtError
    # @return the decoded token
    def validate!(jwt)
      raise InvalidJwtError.invalid_token if @store.expired?(jwt)

      begin
        token = decode(jwt)
      rescue JWT::DecodeError
        raise InvalidJwtError.invalid_token
      rescue JWT::ExpiredSignature
        raise InvalidJwtError.expired_token
      end

      validate_token_claims(token)

      token
    end

    # For the given encoded JWT
    # check to see if it is a valid token
    #
    # @param jwt
    # @return the decoded token
    def validate(jwt)
      validate!(jwt)
    rescue InvalidJwtError
    end

    # For the given encoded JWT
    # check to see if it is a valid token
    #
    # @param jwt
    # @return bool
    def valid?(jwt)
      true if validate!(jwt)
    rescue InvalidJwtError
      false
    end

    private

    # Generates an expiry date for out token
    # for redis
    #
    # @param token the decoded token
    # @return the expiry in seconds
    def invalidation_expiry_for_token(token)
      date = DateTime.iso8601(token['exp'])
      expires = date - DateTime.now
      ((expires) * 24 * 60 * 60).to_i
    end

    # Facade for the JWT encode methods
    #
    # @param Hash claims
    # @return the encoded token
    def encode(claims)
      JWT.encode(payload(claims), secret, @config.hashing_method)
    end

    # Facade for the JWT decode method
    #
    # @param String token
    # @return the decoded token
    def decode(token)
      JWT.decode(token, secret).first
    end

    # Gets the jwt secret from the
    # application secrets
    #
    # @return the jwt secret
    def secret
      Rails.application.secrets[:jwt_secret]
    end

    # Given given the user claims produces a token object
    # to be issued
    #
    # @param Hash user_claims
    # @return a hash ready to be jwt encoded
    def payload(user_claims)
      defaul_claims.merge(user_claims)
    end

    # Checks the claims of a token
    # @param String token the decoded token
    def validate_token_claims(token)
      raise InvalidJwtError.early_token if token['nbf'] > Time.now

      raise InvalidJwtError.bad_issuer if token['iss'] != @config.issuer

      raise InvalidJwtError.lousy_audience if token['aud'] != @config.audience
    end

    # The default claims
    #
    # @return a hash of the claims
    def defaul_claims
      expires = @config.expiry.from_now.iso8601
      now = DateTime.now.iso8601

      {
        iss: @config.issuer,            # issuer
        aud: @config.default_audience,  # audience
        exp: expires,                   # expiration time
        nbf: now,                       # not before
        iat: now,                       # issued at
        jti: SecureRandom.uuid          # JWT ID
      }
    end

  end

end
