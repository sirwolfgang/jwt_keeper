module Keeper
  class Token
    attr_accessor :claims

    # Initalizes a new web token
    # @param private_claims [Hash] the custom claims to encode
    def initialize(private_claims = {})
      @claims = {
        iss: Keeper.configuration.issuer,               # issuer
        aud: Keeper.configuration.audience,             # audience
        exp: Keeper.configuration.expiry.from_now.to_i, # expiration time
        nbf: DateTime.now.to_i,                         # not before
        iat: DateTime.now.to_i,                         # issued at
        jti: SecureRandom.uuid                          # JWT ID
      }.merge(private_claims)
    end

    # Creates a new web token
    # @param private_claims [Hash] the custom claims to encode
    # @return [Token] token object
    def self.create(private_claims)
      new(private_claims)
    end

    # Decodes and validates an existing token
    # @param raw_token [String] the raw token
    # @return [Token] token object
    def self.find(raw_token)
      claims = decode(raw_token)
      return nil if claims.nil?

      new_token = new(claims)
      return nil if new_token.revoked?
      new_token
    end

    # Sets a token to the pending rotation state. The expire is set to the maxium possible time but
    # is inherently ignored by the token's exp check and then rewritten with the revokation on
    # rotate.
    # @param token_jti [String] the token unique id
    def self.rotate(token_id)
      Datastore.rotate(token_id, Keeper.configuration.expiry.from_now.to_i)
    end

    # Revokes a web token
    def revoke
      return if invalid?
      Datastore.revoke(claims[:jti], claims[:exp] - DateTime.now.to_i)
    end

    # Revokes and creates a new web token
    # @return [String] new token
    def rotate
      revoke

      new_token = self.class.new(claims.except(:iss, :aud, :exp, :nbf, :iat, :jti))
      @claims = new_token.claims
      new_token
    end

    # Checks if a web token has been revoked
    # @return [Boolean]
    def revoked?
      Datastore.revoked?(claims[:jti])
    end

    # Checks if a web token is pending a rotation
    # @return [Boolean]
    def pending?
      Datastore.pending?(claims[:jti])
    end

    # Checks if the token valid?
    # @return [Boolean]
    def valid?
      !invalid?
    end

    # Checks if the token invalid?
    # @return [Boolean]
    def invalid?
      self.class.decode(encode).nil? || revoked?
    end

    # Encodes the jwt
    # @return [String]
    def to_jwt
      encode
    end
    alias_method :to_s, :to_jwt

    private

    # @!visibility private
    def encode
      JWT.encode(claims, Keeper.configuration.secret, Keeper.configuration.algorithm)
    end

    # @!visibility private
    def self.decode(raw_token)
      JWT.decode(raw_token, Keeper.configuration.secret, true,
                 algorithm: Keeper.configuration.algorithm,
                 verify_iss: true,
                 verify_aud: true,
                 verify_iat: true,
                 verify_sub: false,
                 verify_jti: false,
                 leeway: 0,

                 iss: Keeper.configuration.issuer,
                 aud: Keeper.configuration.audience
                ).first.symbolize_keys

    rescue JWT::DecodeError
      return nil
    end
  end
end
