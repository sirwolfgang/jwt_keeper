require 'spec_helper'

RSpec.describe Hotel::Configuration do
  it { expect have_constant('DEFAULTS') }
end
