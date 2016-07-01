require 'jwt_keeper'
require 'rails'

module JWTKeeper
  # Includes JWTKeeper into ActionController
  class Engine < ::Rails::Engine
    initializer 'extend Controller with jwt_keeper' do |_app|
      ActionController::Base.send(:include, JWTKeeper::Controller)
    end
  end
end
