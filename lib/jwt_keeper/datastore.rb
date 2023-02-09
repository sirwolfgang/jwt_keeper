module JWTKeeper
  module Datastore
    class << self
      # @!visibility private
      def rotate(jti, seconds)
        set_with_expiry(jti, seconds, :soft)
      end

      # @!visibility private
      def revoke(jti, seconds)
        set_with_expiry(jti, seconds, :hard)
      end

      # @!visibility private
      def pending?(jti)
        value = get(jti)
        value.present? && value.to_sym == :soft
      end

      # @!visibility private
      def revoked?(jti)
        value = get(jti)
        value.present? && value.to_sym == :hard
      end

      private

      # @!visibility private
      def set_with_expiry(jti, seconds, type)
        with_redis do |redis|
          if redis.respond_to?(:call) # For RedisClient
            redis.call('SETEX', jti, seconds, type)
          elsif redis.respond_to?(:setex) # For Redis
            redis.setex(jti, seconds, type)
          else
            throw 'Bad Redis Connection'
          end
        end
      end

      # @!visibility private
      def get(jti)
        with_redis do |redis|
          if redis.respond_to?(:call) # For RedisClient
            redis.call('GET', jti)
          elsif redis.respond_to?(:get) # For Redis
            redis.get(jti)
          else
            throw 'Bad Redis Connection'
          end
        end
      end

      # @!visibility private
      def with_redis
        redis = JWTKeeper.configuration.redis_connection

        if redis.respond_to?(:with)
          redis.with do |conn|
            yield conn
          end
        else
          yield(redis)
        end
      end
    end
  end
end
