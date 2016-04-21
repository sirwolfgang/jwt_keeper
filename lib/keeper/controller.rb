module Keeper
  module Controller
    def self.included(klass)
      klass.class_eval do
        include InstanceMethods
      end
    end

    module InstanceMethods
      # Available to be used as a before_action by the application's controllers. This is
      # the main logical section for decoding, and automatically rotating tokens
      def require_authentication
        token = authentication_token
        return not_authenticated if token.nil?

        if token.version_mismatch? || token.pending?
          new_claims = regenerate_claims(token)
          token.rotate(new_claims)
          self.authentication_token = token
        end

        authenticated(token)
      end

      # Invoked by the require_authentication method as part of the automatic rotation
      # process. The application should override this method to include the necessary
      # claims.
      def regenerate_claims(old_token)
      end

      # Moves the authentication_token from the request to the response
      def respond_with_authentication
        response.headers['Authorization'] = request.headers['Authorization']
      end

      # Decodes and returns the token
      def authentication_token
        return nil unless request.headers['Authorization']
        Keeper::Token.find(request.headers['Authorization'].split.last)
      end

      # Assigns a token to the request to act as a single source of truth
      def authentication_token=(token)
        request.headers['Authorization'] = "Bearer #{token.to_jwt}"
      end

      # Used when a user tries to access a page while logged out, is asked to login,
      # and we want to return him back to the page he originally wanted.
      def redirect_back_or_to(url, flash_hash = {})
        redirect_to(session[:return_to_url] || url, flash: flash_hash)
        session[:return_to_url] = nil
      end

      # The default action for denying non-authenticated connections.
      # You can override this method in your controllers
      def not_authenticated
        redirect_to root_path
      end

      # The default action for accepting authenticated connections.
      # You can override this method in your controllers
      def authenticated(token)
      end
    end
  end
end
