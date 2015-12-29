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

    self.markdown ||= Markdown.new
  end
end
