# frozen_string_literal: true

module Regresso
  class Difference
    attr_reader :path, :old_value, :new_value, :type

    # @param path [Regresso::JsonPath]
    # @param old_value [Object]
    # @param new_value [Object]
    def initialize(path:, old_value:, new_value:)
      @path = path
      @old_value = old_value
      @new_value = new_value
      @type = determine_type
      freeze
    end

    # Returns a human-readable diff description.
    #
    # @return [String]
    def to_s
      "#{path}: #{old_value.inspect} -> #{new_value.inspect}"
    end

    private

    def determine_type
      return :added if old_value.nil?
      return :removed if new_value.nil?

      :changed
    end
  end
end
