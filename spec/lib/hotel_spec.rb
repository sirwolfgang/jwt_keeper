require 'spec_helper'

describe Hotel do
  it { expect respond_to(:configure) }
  it { expect respond_to(:token) }
  it { expect respond_to(:configuration) }
end
