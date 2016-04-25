require 'spec_helper'

RSpec.describe JWTKeeper::Configuration do
  it { expect have_constant('DEFAULTS') }
end
