require 'spec_helper'

RSpec.describe Keeper do
  describe 'Controller' do
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

    before(:each) do
      Keeper.configure(Keeper::Configuration.new(test_config))
    end

    subject(:test_controller) do
      instance = Class.new do
        attr_accessor :private_claims
        include RSpec::Mocks::ExampleMethods
        include Keeper::Controller

        def session
          { return_to_url: 'http://www.example.com' }
        end

        def root_path
          '/'
        end

        def redirect_to(path, message = nil)
        end

        def request
          @request ||= instance_double('Request',
                                       headers: instance_double('Headers',
                                                                :[] => "Bearer #{Keeper.create(private_claims)}"
                                                               )
                                      )
        end
      end.new

      instance.private_claims = { claim: "Jet fuel can't melt steel beams" }
      instance
    end

    describe '#included' do
      it { is_expected.to respond_to(:require_authentication) }
      it { is_expected.to respond_to(:request_decoded_token) }
      it { is_expected.to respond_to(:request_raw_token) }
      it { is_expected.to respond_to(:redirect_back_or_to) }
      it { is_expected.to respond_to(:not_authenticated) }
    end

    describe '.require_authentication' do
      context 'valid request in token' do
        before do
          allow(test_controller).to receive(:authenticated)
        end

        it 'calls authenticated' do
          subject.require_authentication
          expect(subject).to have_received(:authenticated).once
        end
      end
      context 'invalid request in token' do
        before do
          subject.private_claims = { exp: 3.hours.ago }
          allow(test_controller).to receive(:not_authenticated)
        end

        it 'calls not_authenticated' do
          subject.require_authentication
          expect(subject).to have_received(:not_authenticated).once
        end
      end
    end

    describe '.request_decoded_token' do
      context 'valid request in token' do
        it 'returns the decoded token from the current request' do
          expect(subject.request_decoded_token['claim']).to eq "Jet fuel can't melt steel beams"
        end
      end
      context 'no token in request' do
        before do
          subject.private_claims = { exp: 3.hours.ago }
        end

        it 'returns nil' do
          expect(subject.request_decoded_token).to be nil
        end
      end
    end

    describe '.request_raw_token' do
      it 'returns the raw token' do
        expect(subject.request_raw_token).to be_instance_of String
      end
    end

    describe '.redirect_back_or_to' do
      let(:path) { 'http://www.example.com' }

      before do
        allow(test_controller).to receive(:redirect_to)
      end

      it 'it calls redirect_to' do
        subject.redirect_back_or_to(path)
        expect(subject).to have_received(:redirect_to).with(path, anything)
      end
    end

    describe '.not_authenticated' do
      before do
        allow(test_controller).to receive(:redirect_to)
      end

      it 'it calls redirect_to' do
        subject.not_authenticated
        expect(subject).to have_received(:redirect_to).with('/')
      end
    end
  end
end
