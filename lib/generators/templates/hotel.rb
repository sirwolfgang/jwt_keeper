# Hotel configuration
#
# @yield configuration for Hotel
# @yieldparam config
# @yieldreturn config
Hotel.configure do |config|
  config.options = {

    # The time to expire for the tokens
    # expiry:           24.hours,

    # The hashing method to for the tokens
    #hashing_method:    'HS512',

    # the issuer of the tokens
    #issuer:            'api.example.com',

    # the default audience of the tokens
    #default_audience:  'example.com',

    # the location of redis config file
    #redis_config: File.join(Rails.root, 'config', 'redis.yml')
  }
end
