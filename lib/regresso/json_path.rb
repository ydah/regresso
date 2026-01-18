# frozen_string_literal: true

module Regresso
  class JsonPath
    attr_reader :segments

    # Returns the root path.
    #
    # @return [Regresso::JsonPath]
    def self.root
      new([])
    end

    # @param segments [Array<String,Integer>]
    def initialize(segments)
      @segments = segments.dup.freeze
      freeze
    end

    # Returns a new path with the segment appended.
    #
    # @param segment [String,Integer]
    # @return [Regresso::JsonPath]
    def /(segment)
      self.class.new(segments + [segment])
    end

    # Returns the string representation of the path.
    #
    # @return [String]
    def to_s
      return "$" if segments.empty?

      segments.reduce("$") do |path, segment|
        if segment.is_a?(Integer)
          "#{path}[#{segment}]"
        else
          "#{path}.#{segment}"
        end
      end
    end

    # Compares paths by string representation.
    #
    # @param other [Object]
    # @return [Boolean]
    def ==(other)
      return false unless other.respond_to?(:to_s)

      to_s == other.to_s
    end
  end
end
