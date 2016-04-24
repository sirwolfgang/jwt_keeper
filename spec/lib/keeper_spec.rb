require 'spec_helper'

RSpec.describe JWTKeeper do
  describe '#configure' do
    let(:new_config) { { secret: '#configure-secret' } }

    context 'without block' do
      before do
        described_class.configure(JWTKeeper::Configuration.new(new_config))
      end

      it 'sets the configuration based on param' do
        expect(described_class.configuration.secret).to eql new_config[:secret]
      end
    end

    context 'with block' do
      before do
        described_class.configure do |config|
          config.secret = new_config[:secret]
        end
      end

      it 'sets configuration based on the block' do
        expect(described_class.configuration.secret).to eql new_config[:secret]
      end
    end
  end
end
