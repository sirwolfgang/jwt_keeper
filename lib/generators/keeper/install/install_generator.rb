require 'rails/generators/base'

module Keeper
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../../../templates', __FILE__)

    # Copies the default config
    #
    # @example Install
    #   rails generate keeper:install
    def copy_files
      copy_file 'keeper.rb', 'config/initializers/keeper.rb'
    end
  end
end
