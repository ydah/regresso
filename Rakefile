# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

Dir.glob(File.join(__dir__, "lib/regresso/tasks/**/*.rake")).each { |path| load path }
