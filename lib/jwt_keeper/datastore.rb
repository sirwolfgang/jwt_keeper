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
        JWTKeeper.configuration.redis_connection.setex(jti, seconds, type)
      end

      # @!visibility private
      def get(jti)
        JWTKeeper.configuration.redis_connection.get(jti)
      end
    end
  end
end
