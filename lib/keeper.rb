require 'jwt'
require 'redis'
require 'keeper/version'
require 'keeper/exceptions'
require 'keeper/configuration'
require 'keeper/datastore'
require 'keeper/token'
require 'keeper/controller'

module Keeper
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
