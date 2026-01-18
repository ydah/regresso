# frozen_string_literal: true

require "json"

module Regresso
  class Differ
    def initialize(config)
      @config = config
    end

    def diff(a, b, path = JsonPath.root)
      return [] if should_ignore?(path)

      if a.is_a?(Hash) && b.is_a?(Hash)
        diff_hashes(a, b, path)
      elsif a.is_a?(Array) && b.is_a?(Array)
        diff_arrays(a, b, path)
      else
        diff_values(a, b, path)
      end
    end

    private

    def diff_hashes(a, b, path)
      (a.keys | b.keys).flat_map do |key|
        next_path = path / key
        if a.key?(key) && b.key?(key)
          diff(a[key], b[key], next_path)
        elsif a.key?(key)
          [Difference.new(path: next_path, old_value: a[key], new_value: nil)]
        else
          [Difference.new(path: next_path, old_value: nil, new_value: b[key])]
        end
      end
    end

    def diff_arrays(a, b, path)
      if @config.array_order_sensitive
        max = [a.length, b.length].max
        (0...max).flat_map do |index|
          next_path = path / index
          if index < a.length && index < b.length
            diff(a[index], b[index], next_path)
          elsif index < a.length
            [Difference.new(path: next_path, old_value: a[index], new_value: nil)]
          else
            [Difference.new(path: next_path, old_value: nil, new_value: b[index])]
          end
        end
      else
        sorted_a = sort_by_canonical(a)
        sorted_b = sort_by_canonical(b)
        max = [sorted_a.length, sorted_b.length].max
        (0...max).flat_map do |index|
          next_path = path / index
          if index < sorted_a.length && index < sorted_b.length
            diff(sorted_a[index], sorted_b[index], next_path)
          elsif index < sorted_a.length
            [Difference.new(path: next_path, old_value: sorted_a[index], new_value: nil)]
          else
            [Difference.new(path: next_path, old_value: nil, new_value: sorted_b[index])]
          end
        end
      end
    end

    def diff_values(a, b, path)
      return [] if values_equal?(a, b, path)

      [Difference.new(path: path, old_value: a, new_value: b)]
    end

    def values_equal?(a, b, path)
      return true if a == b

      if @config.type_coercion
        coerced_a = numeric_value(a)
        coerced_b = numeric_value(b)
        return numeric_equal?(coerced_a, coerced_b, path) if coerced_a && coerced_b
      end

      if a.is_a?(Numeric) && b.is_a?(Numeric)
        numeric_equal?(a, b, path)
      end
    end

    def numeric_equal?(a, b, path)
      tolerance = @config.tolerance_for(path)
      (a.to_f - b.to_f).abs <= tolerance
    end

    def numeric_value(value)
      return value.to_f if value.is_a?(Numeric)
      return value.to_s.to_f if value.is_a?(String) && value.match?(/\A-?\d+(\.\d+)?\z/)

      nil
    end

    def should_ignore?(path)
      @config.ignored?(path)
    end

    def sort_by_canonical(array)
      array.sort_by { |value| canonical_value(value) }
    end

    def canonical_value(value)
      case value
      when Hash
        "{" + value.sort_by { |k, _| k.to_s }
                        .map { |k, v| "#{k}:#{canonical_value(v)}" }
                        .join(",") + "}"
      when Array
        "[" + value.map { |v| canonical_value(v) }.join(",") + "]"
      else
        value.inspect
      end
    end
  end
end
