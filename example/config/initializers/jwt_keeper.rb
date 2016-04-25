JWTKeeper.configure do |config|
  config.expiry           = 1.hour
  config.algorithm        = 'HS512'
  config.secret           = 'secret'
  config.issuer           = '.localhost'
  config.audience         = 'localhost'
  config.redis_connection = Redis.new(url: ENV['REDIS_URL'])
  config.version          = 1
  config.cookie_lock      = true
  config.cookie_secure    = !(Rails.env.test? || Rails.env.development?)
end
