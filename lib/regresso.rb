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
require_relative "regresso/adapters/database"
require_relative "regresso/adapters/database_snapshot"
require_relative "regresso/adapters/graphql"
require_relative "regresso/adapters/graphql_batch"
require_relative "regresso/snapshot_manager"
require_relative "regresso/reporter"

module Regresso
  class Error < StandardError; end

  class << self
    attr_accessor :configuration

    # Yields the global configuration.
    #
    # @yieldparam config [Regresso::Configuration]
    # @return [void]
    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

    # Resets the global configuration to defaults.
    #
    # @return [void]
    def reset_configuration!
      self.configuration = Configuration.new
    end
  end
end
