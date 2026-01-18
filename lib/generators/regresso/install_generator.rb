# frozen_string_literal: true

require "rails/generators"

module Regresso
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def create_initializer
        copy_file "regresso.rb", "config/initializers/regresso.rb"
      end

      def create_snapshot_directory
        empty_directory "spec/snapshots/regresso"
        create_file "spec/snapshots/regresso/.gitkeep"
      end

      def add_to_gitignore
        append_to_file ".gitignore", "\n# Regresso temporary files\nspec/snapshots/regresso/*.tmp\n"
      end
    end
  end
end
