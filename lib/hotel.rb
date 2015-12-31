require 'jwt'
require 'redis'
require 'hotel/version'
require 'hotel/exceptions'
require 'hotel/configuration'
require 'hotel/datastore'
require 'hotel/token'

module Hotel
  class << self
    attr_reader :configuration, :datastore
  end

  # Creates/sets a new configuration for the gem, yield a configuration object
  # @param new_configuration [Configuration] new configuration
  # @return [Configuration] the frozen configuration
  def self.configure(new_configuration = Configuration.new)
    yield(new_configuration) if block_given?

    @configuration = new_configuration.freeze
  end
end
