module Hotel

  # This class provides our custom error messages
  class InvalidJwtError < StandardError

    class << self

      # The token is invalid
      #
      # @return InvalidJwtError
      def invalid_token
        new('Client authentication required! Invalid JWT')
      end

      # The token expiry claim is invalid
      #
      # @return InvalidJwtError
      def expired_token
        new('Client authentication required! Invalid JWT: Expired token')
      end

      # The token not before claim is invalid
      #
      # @return InvalidJwtError
      def early_token
        new('Client authentication required! Invalid JWT: Received token too early')
      end

      # The token issuer claim is invalid
      #
      # @return InvalidJwtError
      def bad_issuer
        new('Client authentication required! Invalid JWT: Bad issuer')
      end

      # The token audience claim is invalid
      #
      # @return InvalidJwtError
      def lousy_audience
        new('Client authentication required! Invalid JWT: Lousy audience')
      end

    end

  end

end
