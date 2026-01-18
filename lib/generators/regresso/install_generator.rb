# frozen_string_literal: true

require "rails/generators"

module Regresso
  # Rails generators for Regresso setup.
  module Generators
    # Installs Regresso initializer and snapshot directories.
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      # Creates config/initializers/regresso.rb.
      def create_initializer
        copy_file "regresso.rb", "config/initializers/regresso.rb"
      end

      # Creates the snapshot directory with a .gitkeep file.
      def create_snapshot_directory
        empty_directory "spec/snapshots/regresso"
        create_file "spec/snapshots/regresso/.gitkeep"
      end

      # Adds Regresso snapshot temp files to .gitignore.
      def add_to_gitignore
        append_to_file ".gitignore", "\n# Regresso temporary files\nspec/snapshots/regresso/*.tmp\n"
      end
    end
  end
end
