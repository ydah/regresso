# frozen_string_literal: true

module Regresso
  # Stores comparison settings used by {Regresso::Differ} and {Regresso::Comparator}.
  class Configuration
    # Default numeric tolerance applied when no path-specific override exists.
    #
    # @return [Float]
    attr_accessor :default_tolerance

    # Paths or patterns to ignore during comparison.
    #
    # @return [Array<String,Regexp>]
    attr_accessor :ignore_paths

    # Per-path tolerance overrides keyed by JSON path string.
    #
    # @return [Hash{String => Float}]
    attr_accessor :tolerance_overrides

    # Whether array order must match during comparison.
    #
    # @return [Boolean]
    attr_accessor :array_order_sensitive

    # Whether numeric strings should be coerced when comparing.
    #
    # @return [Boolean]
    attr_accessor :type_coercion

    def initialize
      @default_tolerance = 0.0
      @ignore_paths = []
      @tolerance_overrides = {}
      @array_order_sensitive = true
      @type_coercion = true
    end

    # Returns tolerance for a given path.
    #
    # @param path [Regresso::JsonPath]
    # @return [Float]
    def tolerance_for(path)
      @tolerance_overrides[path.to_s] || @default_tolerance
    end

    # Checks if a path should be ignored.
    #
    # @param path [Regresso::JsonPath]
    # @return [Boolean]
    def ignored?(path)
      @ignore_paths.any? { |pattern| path_matches?(path, pattern) }
    end

    # Merges another configuration into a new configuration.
    #
    # @param other [Regresso::Configuration]
    # @return [Regresso::Configuration]
    def merge(other)
      dup.tap do |config|
        unless other.default_tolerance.nil?
          config.default_tolerance = other.default_tolerance
        end

        config.ignore_paths += other.ignore_paths if other.ignore_paths
        config.tolerance_overrides.merge!(other.tolerance_overrides) if other.tolerance_overrides

        unless other.array_order_sensitive.nil?
          config.array_order_sensitive = other.array_order_sensitive
        end

        unless other.type_coercion.nil?
          config.type_coercion = other.type_coercion
        end
      end
    end

    private

    def path_matches?(path, pattern)
      case pattern
      when Regexp
        path.to_s.match?(pattern)
      when String
        path_string = path.to_s
        path_string == pattern || path_string.end_with?(pattern)
      else
        false
      end
    end
  end
end
