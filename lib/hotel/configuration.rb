module Hotel

  # Container object for options
  # parsed by initializer
  class Configuration < OpenStruct

    DEFAULTS = {
      hashing_method: 'HS512',
      expiry: 24.hours,
      issuer: 'api.example.com',
      default_audience: 'example.com',
      redis_config: nil
    }

    # Creates a Configuration object with blank options
    def initialize(params = {})
      super(DEFAULTS.merge(params))
    end

  end

end
