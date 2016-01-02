module Keeper
  module Controller
    def self.included(klass)
      klass.class_eval do
        include InstanceMethods
      end
    end

    module InstanceMethods
      def require_authentication
        decoded_token = request_decoded_token
        if decoded_token.nil?
          not_authenticated
        else
          authenticated(decoded_token)
        end
      end

      def request_decoded_token
        Keeper.decode_and_validate(request_raw_token)
      end

      def request_raw_token
        request.headers['Authorization'][/[A-Za-z0-9\-_=]+\.[A-Za-z0-9\-_=]+\.?[A-Za-z0-9\-_=]+/]
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

      def authenticated(decoded_token)
      end
    end
  end
end
