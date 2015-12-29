module Hotel

  # Container object for options
  # parsed by initializer
  #
  # @attr [hash] options
  class Configuration
    @@options

    attr_accessor :options

    # Creates a Configuration object with blank options
    def initialize
      @@options = {}
    end

    def hashing_method
      @@options.hashing_method
    end

    def expiry
      @@options.expiry
    end

    def issuer
      @@options.issuer
    end

    def audience
      @@options.default_audience
    end
  end
end
