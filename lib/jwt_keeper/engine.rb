require 'jwt_keeper'
require 'rails'

module JWTKeeper
  # The Sorcery engine takes care of extending ActiveRecord (if used) and ActionController,
  # With the plugin logic.
  class Engine < ::Rails::Engine
    initializer 'extend Controller with jwt_keeper' do |_app|
      ActionController::Base.send(:include, JWTKeeper::Controller)
    end
  end
end
