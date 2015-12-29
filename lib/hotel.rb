require 'hotel/configuration'
require 'hotel/token'
require 'hotel/store'
require 'hotel/invalid_jwt_error'
require 'hotel/version'

# This module encapsulates the functionality
# for generating, retrieving, and validating an
# auth token
module Hotel

  class << self
      attr_accessor :configuration, :token
    end

  # static method to define a Configuration
  # object with the given initialized data
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)

    self.markdown ||= Token.new(self.configuration)
  end
end
