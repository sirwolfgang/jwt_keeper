module Keeper
  class << self
    # TODO: Move into an object

    # Creates a new web token
    # @param private_claims [Hash] the custom claims to encode
    # @return [String] encoded token
    def create(private_claims)
      encode(public_claims.merge(private_claims))
    end

    # Revokes a web token
    # @param raw_token [String] the raw token
    # @return [Hash] decoded_token
    def revoke(raw_token)
      decoded_token = decode_and_validate!(raw_token)
      Datastore.expire(raw_token, invalidation_expiry_for_token(decoded_token)) unless invalid?(raw_token)
      decoded_token
    end

    # Checks if a web token has been revoked
    # @param raw_token [String] the raw token
    # @return [Boolean]
    def revoked?(raw_token)
      Datastore.expired?(raw_token)
    end

    # Revokes and creates a new web token
    # @param raw_token [String] the raw token
    # @return [String] encoded token
    def rotate(raw_token)
      decoded_token = decode_and_validate!(raw_token)
      revoke(raw_token)
      create(decoded_token)
    end

    # Decodes and validates a web token, raises token validation errors
    # @param raw_token [String] the raw token
    # @return [Hash] decoded token
    def decode_and_validate!(raw_token)
      decoded_token = decode!(raw_token)

      fail RevokedTokenError if revoked?(raw_token)

      decoded_token

    rescue JWT::ExpiredSignature => e
      raise ExpiredTokenError, e.message
    rescue JWT::ImmatureSignature => e
      raise EarlyTokenError, e.message
    rescue JWT::InvalidIssuerError => e
      raise BadIssuerError, e.message
    rescue JWT::InvalidAudError => e
      raise LousyAudienceError, e.message
    rescue JWT::DecodeError => e
      raise InvalidTokenError, e.message
    end

    # Decodes and validates a web token, returns nil if invalid
    # @param raw_token [String] the raw token
    # @return [Hash] decoded token
    def decode_and_validate(raw_token)
      decode_and_validate!(raw_token)
    rescue InvalidTokenError
      nil
    end

    # Checks if the token valid?
    # @param raw_token [String] the raw token
    # @return [Boolean]
    def valid?(raw_token)
      !decode_and_validate!(raw_token).nil?
    rescue InvalidTokenError
      false
    end

    # Checks if the token invalid?
    # @param raw_token [String] the raw token
    # @return [Boolean]
    def invalid?(raw_token)
      !valid?(raw_token)
    end

    private

    # @!visibility private
    def invalidation_expiry_for_token(decoded_token)
      decoded_token['exp'].to_i - DateTime.now.to_time.to_i
    end

    # @!visibility private
    def encode(claims)
      JWT.encode(claims, configuration.secret, configuration.algorithm)
    end

    # @!visibility private
    def decode!(raw_token)
      JWT.decode(raw_token, configuration.secret, true,
                 algorithm: configuration.algorithm,
                 verify_iss: true,
                 verify_aud: true,
                 verify_iat: true,
                 verify_sub: false,
                 verify_jti: false,
                 leeway: 0,

                 iss: configuration.issuer,
                 aud: configuration.audience
                ).first
    end

    # @!visibility private
    def public_claims
      {
        iss: configuration.issuer,                       # issuer
        aud: configuration.audience,                     # audience
        exp: configuration.expiry.from_now.to_time.to_i, # expiration time
        nbf: DateTime.now.to_time.to_i,                  # not before
        iat: DateTime.now.to_time.to_i,                  # issued at
        jti: SecureRandom.uuid                           # JWT ID
      }
    end
  end
end
