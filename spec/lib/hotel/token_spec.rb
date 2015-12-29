require 'spec_helper'

describe Hotel::Token do
  subject(:token){
    config = Hotel::Configuration.new
    config.options = {
      expiry: 24.hours,
      hashing_method: 'HS512',
      issuer: 'api.example.com',
      default_audience: 'example.com',
      redis_config: 'spec/fixtures/redis.yml'
    }

    store = Hotel::Store.new(config)
    store.stubs(
      :expire => true,
      :is_expired? => true
    )

    Hotel::Token.new(config, store)
  }

  describe "#generate" do
    it "accepts a string param" do
        token.expects(:encode).with({:sub => 'hello'})
        token.generate("hello")
    end
    it "accepts a hash param" do
      token.expects(:encode).with({:sub => 'hello'})
      token.generate({:sub => "hello"})
    end

    it "generates a token" do
      token.stubs(:secret).returns("secret")

      tok = token.generate({:sub => 'hello'})

      expect(tok).to be_kind_of(String)
    end
  end
end
