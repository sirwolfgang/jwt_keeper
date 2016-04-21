module Keeper
  class Configuration < OpenStruct
    DEFAULTS = {
      algorithm:       'HS512',
      secret:           nil,
      expiry:           24.hours,
      issuer:           'api.example.com',
      audience:         'example.com',
      redis_connection: nil,
      version:          nil
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
        iss: Keeper.configuration.issuer,               # issuer
        aud: Keeper.configuration.audience,             # audience
        exp: Keeper.configuration.expiry.from_now.to_i, # expiration time
        ver: Keeper.configuration.version               # Version
      }
    end
  end
end
