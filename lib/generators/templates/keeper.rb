Keeper.configure do |config|
  # The time to expire for the tokens
  # config.expiry           = 24.hours

  # The hashing method to for the tokens
  # Options:
  #   HS256 - HMAC using SHA-256 hash algorithm (default)
  #   HS384 - HMAC using SHA-384 hash algorithm
  #   HS512 - HMAC using SHA-512 hash algorithm
  #   RS256 - RSA using SHA-256 hash algorithm
  #   RS384 - RSA using SHA-384 hash algorithm
  #   RS512 - RSA using SHA-512 hash algorithm
  #   ES256 - ECDSA using P-256 and SHA-256
  #   ES384 - ECDSA using P-384 and SHA-384
  #   ES512 - ECDSA using P-521 and SHA-512
  # config.hashing_method   = 'HS512',

  # the issuer of the tokens
  # config.issuer           = 'api.example.com',

  # the default audience of the tokens
  # config.default_audience = 'example.com',

  # the location of redis config file
  # config.redis_connection = Redis.new(connection_options)
end
