require 'keeper'
require 'rails'

module Keeper
  # The Sorcery engine takes care of extending ActiveRecord (if used) and ActionController,
  # With the plugin logic.
  class Engine < ::Rails::Engine
    initializer 'extend Controller with keeper' do |app|
      ActionController::Base.send(:include, Keeper::Controller)
    end
  end
end
