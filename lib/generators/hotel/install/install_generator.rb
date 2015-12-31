require 'rails/generators/base'

module Hotel
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../../../templates', __FILE__)

    # Copies the default config
    #
    # @example Install
    #   rails generate hotel:install
    def copy_files
      copy_file 'hotel.rb', 'config/initializers/hotel.rb'
    end
  end
end
