module JWTKeeper
  class Configuration < OpenStruct
    DEFAULTS = {
      algorithm:       'HS512',
      secret:           nil,
      expiry:           24.hours,
      issuer:           'api.example.com',
      audience:         'example.com',
      redis_connection: nil,
      version:          nil,
      cookie_lock:      false,
      cookie_secure:    true,
      cookie_domain:    :all
    }.freeze

    # Creates a new Configuration from the passed in parameters
    # @param params [Hash] configuration options
    # @return [Configuration]
    def initialize(params = {})
      super(DEFAULTS.merge(params))
    end

    # @!visibility private
    def base_claims
      {
        iss: JWTKeeper.configuration.issuer,               # issuer
        aud: JWTKeeper.configuration.audience,             # audience
        exp: JWTKeeper.configuration.expiry.from_now.to_i, # expiration time
        ver: JWTKeeper.configuration.version               # Version
      }
    end

    # @!visibility private
    def cookie_options
      {
        domain: JWTKeeper.configuration.cookie_domain,
        secure: JWTKeeper.configuration.cookie_secure,
        httponly: true
      }
    end
  end
end
