# frozen_string_literal: true

module Regresso
  class JsonPath
    attr_reader :segments

    def self.root
      new([])
    end

    def initialize(segments)
      @segments = segments.dup.freeze
      freeze
    end

    def /(segment)
      self.class.new(segments + [segment])
    end

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

    def ==(other)
      return false unless other.respond_to?(:to_s)

      to_s == other.to_s
    end
  end
end
