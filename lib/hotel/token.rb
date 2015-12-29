# This module encapsulates the functionality
# for generating, retrieving, and validating an
# auth token
module Hotel

  EXPIRY = 24.hours

  HASHING_METHOD = 'HS512'

  ISSUER = 'api.klewk.com'

  AUDIENCE = 'klewk.com'

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

      date = DateTime.iso8601(tok['exp'])
      expires = date - DateTime.now
      seconds = ((expires) * 24 * 60 * 60).to_i

      TokenStore.expire(token, seconds)
    end

    # For a given user generates
    # an encoded JWT
    #
    # @param  user
    # @return string
    def generate(user)

      if user
        return JWT.encode(payload(user.tokenize(request.base_url)), secret, HASHING_METHOD)
      end

      false
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

      sub = parse_token_subject(decoded)
      u = User.find sub['id']

      # sign_in u

      JWT.encode(payload(u.tokenize(request.base_url)), secret, HASHING_METHOD)
    end

    # For the given encoded JWT
    # check to see if it is a valid token
    #
    # @raise []
    # @return [true]
    def validate(jwt)

      if TokenStore.is_expired?(jwt)
        raise InvalidJwtError.invalid_token
      end

      begin
        token = decode_token(jwt)
      rescue JWT::DecodeError
        raise InvalidJwtError.invalid_token
      rescue JWT::ExpiredSignature
        raise InvalidJwtError.expired_token
      end

      if token['nbf'] > Time.now
        raise InvalidJwtError.early_token
      end

      if token['iss'] != 'api.klewk.com'
        raise InvalidJwtError.bad_issuer
      end

      if token['aud'] != 'klewk.com'
        raise InvalidJwtError.lousy_audience
      end

      # TODO: logging

      token
    end

    def decode_token(token)
      JWT.decode(token, secret).first
    end

    # For a given decoded token
    # will try to extract the
    # subject claim
    #
    # @param token
    # @return hash
    def parse_token_subject(token)
      subject = token['sub']

      if subject && subject.json?
        return JSON.parse(subject)
      end

      subject
    end

    # Will check the request headers
    # for the given HTTP-CLIENT-TOKEN
    # and validate the found token
    # TODO: SIGN IN USER
    def require_authentication
      jwt = request.headers['HTTP-CLIENT-TOKEN']

      @token = validate(jwt)
      @token_subject = parse_token_subject(@token)

      @current_user = User.find @token_subject['id']
    end

    # This is a sketchy check
    # it will catch any parse errors
    # only use this if authentication
    # isn't required but could be used
    def try_authentication
      begin
        require_authentication
      rescue
        return
      end
    end

    alias_method :invalidate_token, :invalidate
    alias_method :generate_token, :generate
    alias_method :refresh_token, :refresh

    private

      # Gets the jwt secret from the
      # application secrets
      def secret
        Rails.application.secrets[:jwt_secret]
      end

      # Given a subject produces a token object
      # to be issued
      #
      # @return a hash ready to be jwt encoded
      def payload(subject)
        expires = EXPIRY.from_now.iso8601
        now = DateTime.now.iso8601

        {
          :iss => ISSUER,                    # issuer
          :sub => subject,                   # subject
          :aud => AUDIENCE,                  # audience
          :exp => expires,                   # expiration time
          :nbf => now,                       # not before
          :iat => now,                       # issued at
          :jti => SecureRandom.uuid          # JWT ID
        }
      end
  end
end
