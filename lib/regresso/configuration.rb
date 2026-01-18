# frozen_string_literal: true

module Regresso
  class Configuration
    attr_accessor :default_tolerance,
                  :ignore_paths,
                  :tolerance_overrides,
                  :array_order_sensitive,
                  :type_coercion

    def initialize
      @default_tolerance = 0.0
      @ignore_paths = []
      @tolerance_overrides = {}
      @array_order_sensitive = true
      @type_coercion = true
    end

    def tolerance_for(path)
      @tolerance_overrides[path.to_s] || @default_tolerance
    end

    def ignored?(path)
      @ignore_paths.any? { |pattern| path_matches?(path, pattern) }
    end

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
