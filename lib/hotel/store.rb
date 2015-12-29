module Hotel
  # Wrapper class around redis to preform simple
  # actions to set and get tokens in our store
  class Store

    def initialize(config)

      @config = config
      
      opts = connection_options
      
      puts opts

      @redis = Redis.new(opts)
    end

    # places a token in redis with the current
    # timestamp
    #
    # @param token
    # @param time
    # @return bool
    def expire(token, time)
      set_with_expiry(token, time)
    end

    # Checks to see if the given token is expired
    #
    # @param token
    # @return null|timestamp
    def is_expired?(token)
      get(token).present?
    end

    private

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

    # grabs the correct creds for redis from
    # the yml config file
    #
    # @return hash
    def connection_options
      puts @config
      puts @config.redis_config
      YAML.load(ERB.new(IO.read(@config.redis_config)).result)[Rails.env]
    end
  end
end
