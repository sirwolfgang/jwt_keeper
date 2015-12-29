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
  end
end
