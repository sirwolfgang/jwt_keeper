RSpec.describe JWTKeeper::Datastore do
  include_context 'initialize config'
  let(:jti) { SecureRandom.uuid }

  describe '.rotate' do
    before { described_class.rotate(jti, 30) }

    it 'stores a token_id with a soft expiry' do
      expect(described_class.send(:get, jti)).to eq 'soft'
    end
  end

  describe '.pending?' do
    context 'with a missing token' do
      it 'returns false' do
        expect(described_class.pending?(jti)).to be false
      end
    end

    context 'with a revoked token' do
      before { described_class.revoke(jti, 30) }

      it 'returns false' do
        expect(described_class.pending?(jti)).to be false
      end
    end

    context 'with a pending token' do
      before { described_class.rotate(jti, 30) }

      it 'returns true' do
        expect(described_class.pending?(jti)).to be true
      end
    end
  end

  describe '.revoke' do
    before do
      described_class.revoke(jti, 30)
    end

    it 'stores a token_id with a hard expiry' do
      expect(described_class.send(:get, jti)).to eq 'hard'
    end
  end

  describe '.revoked?' do
    context 'with a missing token' do
      it 'returns false' do
        expect(described_class.revoked?(jti)).to be false
      end
    end

    context 'with a revoked token' do
      before { described_class.revoke(jti, 30) }

      it 'returns true' do
        expect(described_class.revoked?(jti)).to be true
      end
    end

    context 'with a pending token' do
      before { described_class.rotate(jti, 30) }

      it 'returns false' do
        expect(described_class.revoked?(jti)).to be false
      end
    end
  end
end
