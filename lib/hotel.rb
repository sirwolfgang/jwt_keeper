require 'jwt'
require 'redis'
require 'hotel/configuration'
require 'hotel/token'
require 'hotel/store'
require 'hotel/invalid_jwt_error'
require 'hotel/version'

# This module encapsulates the functionality
# for generating, retrieving, and validating an
# auth token
# @attr [Hotel::Configuration] the configuration
# @attr [Hote::Token] a token instance
module Hotel

  attr_accessor :configuration, :token

  # static method to define a Configuration
  # object with the given initialized data
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)

    self.token ||= Token.new(self.configuration, Store.new(self.configuration))
  end

end
