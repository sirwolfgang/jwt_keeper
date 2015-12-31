require 'spec_helper'

RSpec.describe Keeper do
  describe '#configure' do
    let(:test_config) do
      {
        algorithm:        'HS256',
        secret:           'secret',
        expiry:           24.hours,
        issuer:           'api.example.com',
        audience:         'example.com',
        redis_connection: Redis.new(url: ENV['REDIS_URL'])
      }
    end

    context 'without block' do
      before do
        described_class.configure(Keeper::Configuration.new(test_config))
      end

      it 'sets the configuration based on param' do
        expect(described_class.configuration.secret).to eql test_config[:secret]
      end
    end

    context 'with block' do
      before do
        described_class.configure do |config|
          config.secret = test_config[:secret]
        end
      end

      it 'sets configuration based on the block' do
        expect(described_class.configuration.secret).to eql test_config[:secret]
      end
    end
  end
end
