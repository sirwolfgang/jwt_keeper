require 'spec_helper'

RSpec.describe JWTKeeper do
  describe 'Controller' do
    include_context 'initialize config'

    let(:token) { JWTKeeper::Token.create(claim: "Jet fuel can't melt steel beams") }
    subject(:test_controller) do
      instance = Class.new do
        attr_accessor :request, :response, :cookies
        include RSpec::Mocks::ExampleMethods
        include JWTKeeper::Controller

        def session
          { return_to_url: 'http://www.example.com' }
        end

        def root_path
          '/'
        end

        def regenerate_claims(_old_token)
          { regenerate_claims: true }
        end

        def redirect_to(path, message = nil)
        end
      end.new

      instance.request =
        instance_double('Request', headers: { 'Authorization' => "Bearer #{token}" })
      instance.response =
        instance_double('Response', headers: {})
      instance.cookies = {}
      instance
    end

    describe '#included' do
      it { is_expected.to respond_to(:require_authentication) }
      it { is_expected.to respond_to(:read_authentication_token) }
      it { is_expected.to respond_to(:write_authentication_token) }
      it { is_expected.to respond_to(:clear_authentication_token) }
      it { is_expected.to respond_to(:redirect_back_or_to) }
      it { is_expected.to respond_to(:not_authenticated) }
      it { is_expected.to respond_to(:authenticated) }
      it { is_expected.to respond_to(:regenerate_claims) }
    end

    describe '#require_authentication' do
      context 'with valid token' do
        before do
          allow(test_controller).to receive(:authenticated)
        end

        it 'calls authenticated' do
          subject.require_authentication
          expect(subject).to have_received(:authenticated).once
        end

        it 'does not rotates the token' do
          expect { subject.require_authentication }.to_not change {
            subject.read_authentication_token.id
          }
        end
      end

      context 'with expired token' do
        let(:token) { JWTKeeper::Token.create(exp: 3.hours.ago) }
        before do
          allow(test_controller).to receive(:not_authenticated)
        end

        it 'calls not_authenticated' do
          subject.require_authentication
          expect(subject).to have_received(:not_authenticated).once
        end
      end

      context 'with pending token' do
        let(:token) do
          token = JWTKeeper::Token.create({})
          JWTKeeper::Token.rotate(token.id)
          token
        end
        before(:each) do
          allow(test_controller).to receive(:authenticated)
        end

        it 'calls authenticated' do
          subject.require_authentication
          expect(subject).to have_received(:authenticated).once
        end

        it 'rotates the token' do
          expect { subject.require_authentication }.to change {
            subject.read_authentication_token.id
          }
        end
      end

      context 'with version_mismatch token' do
        let(:token) { JWTKeeper::Token.create(ver: 'mismatch') }
        before(:each) do
          allow(test_controller).to receive(:authenticated)
        end

        it 'calls authenticated' do
          subject.require_authentication
          expect(subject).to have_received(:authenticated).once
        end

        it 'rotates the token' do
          expect { subject.require_authentication }.to change {
            subject.read_authentication_token.id
          }
        end
      end
    end

    describe '#regenerate_claims' do
      let(:token) do
        token = JWTKeeper::Token.create({})
        JWTKeeper::Token.rotate(token.id)
        token
      end
      before(:each) do
        allow(test_controller).to receive(:authenticated)
      end

      pending 'is used to update the token claims on rotation' do
        expect(subject.read_authentication_token.claims[:regenerate_claims]).to be nil
        expect { subject.require_authentication }.to change(subject, :read_authentication_token)
        expect(subject.read_authentication_token.claims[:regenerate_claims]).to be true
      end
    end

    describe '#redirect_back_or_to' do
      let(:path) { 'http://www.example.com' }

      before do
        allow(test_controller).to receive(:redirect_to)
      end

      it 'it calls redirect_to' do
        subject.redirect_back_or_to(path)
        expect(subject).to have_received(:redirect_to).with(path, anything)
      end
    end

    describe '#not_authenticated' do
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
