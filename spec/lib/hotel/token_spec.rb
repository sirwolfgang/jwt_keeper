require 'spec_helper'

RSpec.describe Hotel do
  describe 'Token' do
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
    let(:private_claims) { { claim: "Jet fuel can't melt steel beams" } }
    let(:raw_token)      { described_class.create(private_claims) }

    before(:each) do
      Hotel.configure(Hotel::Configuration.new(test_config))
    end

    describe '#create' do
      it 'returns an encoded token' do
        expect(described_class.create(private_claims)).to be_instance_of String
      end
    end

    describe '#revoke' do
      it 'invalidates the token' do
        expect(described_class.valid?(raw_token)).to eq true
        expect(described_class.revoked?(raw_token)).to eq false

        expect(described_class.revoke(raw_token))

        expect(described_class.valid?(raw_token)).to eq false
        expect(described_class.revoked?(raw_token)).to eq true
      end
    end

    describe '#revoked?' do
      context 'when token has been revoked' do
        before do
          described_class.revoke(raw_token)
        end

        it 'returns true' do
          expect(described_class.revoked?(raw_token)).to eq true
        end
      end

      context 'when token is valid' do
        it 'returns false' do
          expect(described_class.revoked?(raw_token)).to eq false
        end
      end
    end

    describe '#rotate' do
      let(:new_token) { described_class.rotate(raw_token) }
      before do
        new_token
      end

      it 'revokes the old token false' do
        expect(described_class.valid?(raw_token)).to eq false
      end

      it 'creates a new valid token' do
        expect(described_class.valid?(new_token)).to eq true
      end

      it 'creates a token with the same claims' do
        expect(described_class.decode_and_validate(new_token)['claim']).to eq private_claims[:claim]
      end
    end

    describe '#decode_and_validate!' do
      context 'valid token' do
        it 'returns a decoded token' do
          expect(described_class.decode_and_validate!(raw_token)['claim']).to eq private_claims[:claim]
        end
      end

      context 'invalid token' do
        let(:test_config) do
          {
            algorithm:        nil,
            secret:           'secret',
            expiry:           24.hours,
            issuer:           'api.example.com',
            audience:         'example.com',
            redis_connection: Redis.new(url: ENV['REDIS_URL'])
          }
        end

        it 'raises InvalidTokenError' do
          expect { described_class.decode_and_validate!(raw_token) }.to raise_error Hotel::InvalidTokenError
        end
      end

      context 'expired token' do
        let(:raw_token) { described_class.create(private_claims.merge(exp: DateTime.now.to_time.to_i - 1)) }

        it 'raises ExpiredTokenError' do
          expect { described_class.decode_and_validate!(raw_token) }.to raise_error Hotel::ExpiredTokenError
        end
      end

      context 'early' do
        let(:raw_token) { described_class.create(private_claims.merge(nbf: DateTime.now.to_time.to_i + 100)) }

        it 'raises EarlyTokenError' do
          expect { described_class.decode_and_validate!(raw_token) }.to raise_error Hotel::EarlyTokenError
        end
      end

      context 'bad issuer' do
        let(:raw_token) { described_class.create(private_claims.merge(iss: 'wrong')) }

        it 'raises BadIssuerError' do
          expect { described_class.decode_and_validate!(raw_token) }.to raise_error Hotel::BadIssuerError
        end
      end

      context 'lousy audience' do
        let(:raw_token) { described_class.create(private_claims.merge(aud: 'wrong')) }

        it 'raises LousyAudienceError' do
          expect { described_class.decode_and_validate!(raw_token) }.to raise_error Hotel::LousyAudienceError
        end
      end
    end

    describe '#decode_and_validate' do
      context 'valid token' do
        it 'returns the decoded token' do
          expect(described_class.decode_and_validate(raw_token)['claim']).to eq private_claims[:claim]
        end
      end

      context 'invalid token' do
        let(:raw_token) { described_class.create(private_claims.merge(aud: 'wrong')) }

        it 'returns nil' do
          expect(described_class.decode_and_validate(raw_token)).to eq nil
        end
      end
    end

    describe '#valid?' do
      context 'when invalid' do
        before do
          Hotel.configure(Hotel::Configuration.new(test_config.merge(expiry: -1.hours)))
        end

        it 'returns false' do
          expect(described_class.valid?(raw_token)).to eq false
        end
      end

      context 'when valid' do
        it 'returns true' do
          expect(described_class.valid?(raw_token)).to eq true
        end
      end
    end

    describe '#invalid?' do
      context 'when invalid' do
        it 'returns true' do
          expect(described_class.valid?(raw_token)).to eq true
        end
      end

      context 'when valid' do
        before do
          Hotel.configure(Hotel::Configuration.new(test_config.merge(expiry: -1.hours)))
        end

        it 'returns false' do
          expect(described_class.valid?(raw_token)).to eq false
        end
      end
    end

  end
end

#
# def rotate(token)
#   decoded_token = validate!(token)
#   revoke(token)
#   create(decoded_token)
# end
#
# def validate!(token)
#   decoded_token = decode!(token)
#
#   fail RevokedTokenError if revoked?(token)
#
#   decoded_token
#
# rescue JWT::DecodeError
#   raise InvalidTokenError
# rescue JWT::ExpiredSignature
#   raise ExpiredTokenError
# rescue JWT::ImmatureSignature
#   raise EarlyTokenError
# rescue JWT::InvalidIssuerError
#   raise BadIssuerError
# rescue JWT::InvalidAudError
#   raise LousyAudienceError
# rescue JWT::InvalidJtiError
#   raise InvalidTokenError
# rescue JWT::InvalidIatError
#   raise InvalidTokenError
# rescue JWT::InvalidSubError
#   raise InvalidTokenError
# end
#
# def validate(token)
#   validate!(token)
# rescue InvalidTokenError
#   nil
# end
#
# def valid?(token)
#   !validate!(token).nil?
# rescue Error
#   false
# end
#
# def invalid?(token)
#   !valid?
# end
