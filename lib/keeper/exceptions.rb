module Keeper
  # The token is invalid
  class InvalidTokenError < StandardError; end

  # The token expiry claim is invalid
  class ExpiredTokenError < InvalidTokenError; end

  # The token was force expired
  class RevokedTokenError < InvalidTokenError; end

  # The token not before claim is invalid
  class EarlyTokenError < InvalidTokenError; end

  # The token issuer claim is invalid
  class BadIssuerError < InvalidTokenError; end

  # The token audience claim is invalid
  class LousyAudienceError < InvalidTokenError; end
end
