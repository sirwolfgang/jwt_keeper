module Keeper
  module Controller
    def self.included(klass)
      klass.class_eval do
        include InstanceMethods
      end
    end

    module InstanceMethods
      JWT_REGEX = /[A-Za-z0-9\-_=]+\.[A-Za-z0-9\-_=]+\.?[A-Za-z0-9\-_=]+/

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

      def regenerate_claims(_old_token)
        nil
      end

      def respond_with_authentication
        response.headers['Authorization'] = request.headers['Authorization']
      end

      def authentication_token
        return nil unless request.headers['Authorization']
        Keeper::Token.find(request.headers['Authorization'][JWT_REGEX])
      end

      def authentication_token=(token)
        request.headers['Authorization'] = "Bearer #{token.to_jwt}"
      end

      # used when a user tries to access a page while logged out, is asked to login,
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

      def authenticated(token)
      end
    end
  end
end
