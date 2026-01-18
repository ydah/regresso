# frozen_string_literal: true

module Regresso
  class Result
    attr_reader :source_a, :source_b, :diffs, :config

    def initialize(source_a:, source_b:, diffs:, config:)
      @source_a = source_a
      @source_b = source_b
      @diffs = diffs
      @config = config
    end

    def passed?
      meaningful_diffs.empty?
    end

    def failed?
      !passed?
    end

    def meaningful_diffs
      @meaningful_diffs ||= diffs.reject { |diff| config.ignored?(diff.path) }
    end

    def summary
      {
        total_diffs: diffs.size,
        meaningful_diffs: meaningful_diffs.size,
        ignored_diffs: diffs.size - meaningful_diffs.size,
        passed: passed?
      }
    end

    def to_report(format: :text)
      unless defined?(Regresso::Reporter)
        raise NotImplementedError, "Reporter is not available"
      end

      Reporter.new(self).generate(format)
    end
  end
end
