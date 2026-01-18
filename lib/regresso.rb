# frozen_string_literal: true

require_relative "regresso/version"
require_relative "regresso/json_path"
require_relative "regresso/difference"
require_relative "regresso/configuration"
require_relative "regresso/differ"
require_relative "regresso/result"
require_relative "regresso/comparator"
require_relative "regresso/adapters/base"
require_relative "regresso/adapters/proc"
require_relative "regresso/adapters/json_file"
require_relative "regresso/adapters/csv"
require_relative "regresso/adapters/http"
require_relative "regresso/snapshot_manager"
require_relative "regresso/reporter"

module Regresso
  class Error < StandardError; end

  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

    def reset_configuration!
      self.configuration = Configuration.new
    end
  end
end
