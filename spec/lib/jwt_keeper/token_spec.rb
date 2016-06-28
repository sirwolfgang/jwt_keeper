require 'spec_helper'

module JWTKeeper
  RSpec.describe Token do
    include_context 'initialize config'
    let(:private_claims) { { claim: "Jet fuel can't melt steel beams" } }
    let(:token)          { described_class.create(private_claims) }
    let(:raw_token)      { token.to_jwt }

    describe '.create' do
      subject { described_class.create(private_claims) }

      it { is_expected.to be_instance_of described_class }
      it { expect(subject.claims[:claim]).to eql private_claims[:claim] }

      context 'with cookie_lock enabled' do
        before { JWTKeeper.configure(JWTKeeper::Configuration.new(config.merge(cookie_lock: true))) }
        it { expect(subject.cookie_secret).not_to be_empty }
      end

      context 'when overiding default claims' do
        let(:private_claims) { { exp: 1.minute.from_now.to_i } }

        it { is_expected.to be_instance_of described_class }
        it { expect(subject.claims[:exp]).to eql private_claims[:exp] }
      end
    end

    describe '.find' do
      subject { described_class.find(raw_token) }

      it { is_expected.to be_instance_of described_class }
      it { expect(subject.claims[:claim]).to eql private_claims[:claim] }

      context 'with invalid token' do
        let(:private_claims) { { exp: 1.hour.ago } }
        it { is_expected.to be nil }
      end

      context 'with revoked token' do
        before { described_class.find(raw_token).revoke }
        it { is_expected.to be nil }
      end

      context 'with bad cookie' do
        subject { described_class.find(raw_token, 'BAD_COOKIE') }
        it { is_expected.to be nil }
      end

      context 'with valid cookie' do
        before { JWTKeeper.configure(JWTKeeper::Configuration.new(config.merge(cookie_lock: true))) }
        subject { described_class.find(raw_token, token.cookie_secret) }

        it { is_expected.to be_instance_of described_class }
      end
    end

    describe '.rotate' do
      subject(:token) { described_class.create(private_claims) }
      before(:each) { described_class.rotate(token.id) }

      it 'marks the token for rotation' do
        expect(token.pending?).to eq true
      end
    end

    describe '.revoke' do
      subject(:token) { described_class.create(private_claims) }

      it 'invalidates the token' do
        expect(token.valid?).to eq true
        expect(token.revoked?).to eq false

        expect(described_class.revoke(token.claims[:jti]))

        expect(token.valid?).to eq false
        expect(token.revoked?).to eq true
      end
    end

    describe '#revoke' do
      subject(:token) { described_class.create(private_claims) }

      it 'invalidates the token' do
        expect(token.valid?).to eq true
        expect(token.revoked?).to eq false

        expect(token.revoke)

        expect(token.valid?).to eq false
        expect(token.revoked?).to eq true
      end
    end

    describe '#revoked?' do
      subject(:token) { described_class.create(private_claims) }

      context 'with a revoked token' do
        before { token.revoke }

        it { is_expected.to be_revoked }
      end

      context 'with a pending token' do
        before { described_class.rotate(token.id) }

        it { is_expected.not_to be_revoked }
      end

      context 'with a valid token' do
        it { is_expected.not_to be_revoked }
      end
    end

    describe '#pending?' do
      subject(:token) { described_class.create(private_claims) }

      context 'with a revoked token' do
        before { token.revoke }

        it { is_expected.not_to be_pending }
      end

      context 'with a config pending token' do
        before { token.claims[:ver] = 'version' }

        it { is_expected.to_not be_pending }
      end

      context 'with a redis pending token' do
        before { described_class.rotate(token.id) }

        it { is_expected.to be_pending }
      end

      context 'with a valid token' do
        it { is_expected.not_to be_pending }
      end
    end

    describe '#version_mismatch?' do
      subject(:token) { described_class.create(private_claims) }

      context 'with a revoked token' do
        before { token.revoke }

        it { is_expected.not_to be_version_mismatch }
      end

      context 'with a config pending token' do
        before { token.claims[:ver] = 'version' }

        it { is_expected.to be_version_mismatch }
      end

      context 'with a redis pending token' do
        before { described_class.rotate(token.id) }

        it { is_expected.to_not be_version_mismatch }
      end

      context 'with a valid token' do
        it { is_expected.not_to be_version_mismatch }
      end
    end

    describe '#rotate' do
      before { JWTKeeper.configure(JWTKeeper::Configuration.new(config.merge(cookie_lock: true))) }
      let(:old_token) { described_class.create(private_claims) }
      let(:new_token) { old_token.dup.rotate }
      before { new_token }

      it { expect(old_token).to be_invalid }
      it { expect(new_token).to be_valid }
      it { expect(old_token.claims[:claim]).to eq new_token.claims[:claim] }
      it { expect(old_token.cookie_secret).not_to eq new_token.cookie_secret }
    end

    describe '#valid?' do
      subject { described_class.create(private_claims) }

      context 'when invalid' do
        before { JWTKeeper.configure(JWTKeeper::Configuration.new(config.merge(expiry: -1.hours))) }
        it { is_expected.not_to be_valid }
      end

      context 'when valid' do
        it { is_expected.to be_valid }
      end
    end

    describe '#invalid?' do
      subject { described_class.create(private_claims) }

      context 'when invalid' do
        before { JWTKeeper.configure(JWTKeeper::Configuration.new(config.merge(expiry: -1.hours))) }
        it { is_expected.to be_invalid }
      end

      context 'when valid' do
        it { is_expected.not_to be_invalid }
      end

      context 'with cookie_lock enabled' do
        before { JWTKeeper.configure(JWTKeeper::Configuration.new(config.merge(cookie_lock: true))) }

        context 'when invalid' do
          before { JWTKeeper.configure(JWTKeeper::Configuration.new(config.merge(expiry: -1.hours))) }
          it { is_expected.to be_invalid }
        end

        context 'when valid' do
          it { is_expected.not_to be_invalid }
        end
      end
    end
  end
end
