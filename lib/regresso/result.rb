# frozen_string_literal: true

module Regresso
  # Holds the outcome of comparing two sources.
  class Result
    # @return [Object]
    attr_reader :source_a

    # @return [Object]
    attr_reader :source_b

    # @return [Array<Regresso::Difference>]
    attr_reader :diffs

    # @return [Regresso::Configuration]
    attr_reader :config

    # @param source_a [Object]
    # @param source_b [Object]
    # @param diffs [Array<Regresso::Difference>]
    # @param config [Regresso::Configuration]
    def initialize(source_a:, source_b:, diffs:, config:)
      @source_a = source_a
      @source_b = source_b
      @diffs = diffs
      @config = config
    end

    # @return [Boolean]
    def passed?
      meaningful_diffs.empty?
    end

    # @return [Boolean]
    def failed?
      !passed?
    end

    # Returns diffs not ignored by configuration.
    #
    # @return [Array<Regresso::Difference>]
    def meaningful_diffs
      @meaningful_diffs ||= diffs.reject { |diff| config.ignored?(diff.path) }
    end

    # Returns a summary hash.
    #
    # @return [Hash]
    def summary
      {
        total_diffs: diffs.size,
        meaningful_diffs: meaningful_diffs.size,
        ignored_diffs: diffs.size - meaningful_diffs.size,
        passed: passed?
      }
    end

    # Generates a report string for the given format.
    #
    # @param format [Symbol]
    # @return [String]
    def to_report(format: :text)
      unless defined?(Regresso::Reporter)
        raise NotImplementedError, "Reporter is not available"
      end

      Reporter.new(self).generate(format)
    end
  end
end
