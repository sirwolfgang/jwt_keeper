Hotel.configure do |config|
  # The time to expire for the tokens
  # config.expiry =           24.hours

  # The hashing method to for the tokens
  # config.hashing_method =   'HS512',

  # the issuer of the tokens
  # config.issuer =           'api.example.com',

  # the default audience of the tokens
  # config.default_audience = 'example.com',

  # the location of redis config file
  # config.redis_config = File.join(Rails.root, 'config', 'redis.yml')
end
