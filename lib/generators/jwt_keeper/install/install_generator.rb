require 'rails/generators/base'

module JwtKeeper
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../../../templates', __FILE__)

    # Copies the default config
    #
    # @example Install
    #   rails generate keeper:install
    def copy_files
      copy_file 'jwt_keeper.rb', 'config/initializers/jwt_keeper.rb'
    end
  end
end
