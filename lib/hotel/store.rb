module Hotel
  # Wrapper class around redis to preform simple
  # actions to set and get tokens in our store
  class Store
    class << self
      # places a token in redis with the current
      # timestamp
      #
      # @param token
      # @param time
      # @return bool
      def expire(token, time)
        store.set_with_expiry(token, time)
      end

      # Checks to see if the given token is expired
      #
      # @param token
      # @return null|timestamp
      def is_expired?(token)
        store.get(token).present?
      end

      private

      def store
        @@store ||= Store.new
      end
    end

    def initialize
      @redis = Redis.new(connection_options)
    end

    # Wrapper function around Redis#setex
    #
    # @param token
    # @param expire
    #
    # @return
    def set_with_expiry(token, expire)
      @redis.setex(token, expire, DateTime.now)
    end

    # Wrapper function around Redis#get
    #
    # @param token
    #
    # @return
    def get(token)
      @redis.get(token)
    end

    private

    # grabs the correct creds for redis from
    # the yml config file
    #
    # @return hash
    def connection_options
      env_file = File.join(Rails.root, 'config', 'redis.yml')
      YAML.load(ERB.new(IO.read(env_file)).result)[Rails.env]
    end
  end
end
