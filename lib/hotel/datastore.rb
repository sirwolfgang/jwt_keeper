module Hotel
  module Datastore
    class << self

      # @!visibility private
      def expire(token, time)
        set_with_expiry(token, time)
      end

      # @!visibility private
      def expired?(token)
        get(token).present?
      end

      private

      # @!visibility private
      def set_with_expiry(token, expire)
        Hotel.configuration.redis_connection.setex(token, expire, DateTime.now)
      end

      # @!visibility private
      def get(token)
        Hotel.configuration.redis_connection.get(token)
      end
    end
  end
end
