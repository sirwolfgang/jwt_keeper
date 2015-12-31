module Keeper
  class Configuration < OpenStruct
    DEFAULTS = {
      algorithm:       'HS512',
      secret:           nil,
      expiry:           24.hours,
      issuer:           'api.example.com',
      audience:         'example.com',
      redis_connection: nil
    }

    # Creates a new Configuration from the passed in parameters
    # @param params [Hash] configuration options
    # @return [Configuration]
    def initialize(params = {})
      super(DEFAULTS.merge(params))
    end
  end
end
