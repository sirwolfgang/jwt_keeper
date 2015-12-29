require 'rails'
require 'hotel'

RSpec.configure do |config|
  config.mock_with :mocha
end

RSpec::Matchers.define :have_constant do |const|
  match do |owner|
    owner.const_defined?(const)
  end
end
