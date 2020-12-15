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
        redis = JWTKeeper.configuration.redis_connection

        if redis.is_a?(Redis)
          redis.setex(jti, seconds, type)
        elsif defined?(ConnectionPool) && redis.is_a?(ConnectionPool)
          redis.with { |conn| conn.setex(jti, seconds, type) }
        else
          throw 'Bad Redis Connection'
        end
      end

      # @!visibility private
      def get(jti)
        redis = JWTKeeper.configuration.redis_connection

        if redis.is_a?(Redis)
          redis.get(jti)
        elsif defined?(ConnectionPool) && redis.is_a?(ConnectionPool)
          redis.with { |conn| conn.get(jti) }
        else
          throw 'Bad Redis Connection'
        end
      end
    end
  end
end
