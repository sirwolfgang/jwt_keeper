JWTKeeper.configure do |config|
  # The time to expire for the tokens
  # config.expiry           = 1.hour

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
  # config.algorithm        = 'HS512'

  # the secret in which you data is hash with
  # config.secret           = 'secret'

  # the issuer of the tokens
  # config.issuer           = 'api.example.com'

  # the default audience of the tokens
  # config.audience         = 'example.com'

  # the location of redis config file
  # config.redis_connection = Redis.new(connection_options)

  # A unique idenfitier for the token version.
  # config.version          = 1

  # Use a httponly/secure cookie secret to prevent session hijacking
  # config.cookie_lock      = true

  # Used to turn off TLS only mode on the cookie, for development mode. Defaults to true
  # config.cookie_secure    = !(Rails.env.test? || Rails.env.development?)

  # Used to limit or lock down the allowed domains for the jwt/cookie
  # http://api.rubyonrails.org/classes/ActionDispatch/Cookies.html
  # Defaults the value of :all
  # config.cookie_domain    = :all
end
