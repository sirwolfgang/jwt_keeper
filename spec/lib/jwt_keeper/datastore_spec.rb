RSpec.describe JWTKeeper::Datastore do
  let(:jti) { SecureRandom.uuid }

  shared_examples 'Datastore Specs' do
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

  context 'with Redis' do
    include_context 'initialize config'

    let(:redis_connection) { Redis.new(url: ENV['REDIS_URL']) }

    include_examples 'Datastore Specs'
  end

  context 'with Redis Connection Pool' do
    include_context 'initialize config'

    let(:redis_connection) do
      ConnectionPool.new(size: ENV.fetch('RAILS_MAX_THREADS', 5)) do
        Redis.new(url: ENV['REDISCLOUD_URL'] || 'redis://localhost:6379/')
      end
    end

    include_examples 'Datastore Specs'
  end

  context 'with RedisClient' do
    include_context 'initialize config'

    let(:redis_connection) { RedisClient.new(url: ENV['REDIS_URL']) }

    include_examples 'Datastore Specs'
  end

  context 'with RedisClient Pool' do
    include_context 'initialize config'

    let(:redis_connection) { RedisClient.config(url: ENV['REDIS_URL']).new_pool(size: ENV.fetch('RAILS_MAX_THREADS', 5)) }

    include_examples 'Datastore Specs'
  end
end
