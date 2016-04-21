require 'jwt'
require 'redis'
require 'active_support'
require 'active_support/core_ext/numeric'

require 'jwt_keeper/version'
require 'jwt_keeper/exceptions'
require 'jwt_keeper/configuration'
require 'jwt_keeper/datastore'
require 'jwt_keeper/token'
require 'jwt_keeper/controller'

module JWTKeeper
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

  require 'jwt_keeper/engine' if defined?(Rails)
end
