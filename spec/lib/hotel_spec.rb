require 'spec_helper'

describe Hotel do
  it { should respond_to(:configure) }
  it { should respond_to(:token) }
  it { should respond_to(:configuration) }
end
