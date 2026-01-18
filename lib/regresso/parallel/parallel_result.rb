# frozen_string_literal: true

module Regresso
  module Parallel
    class ParallelResult
      attr_reader :total, :passed, :failed, :errors, :results, :total_duration

      def initialize(total:, passed:, failed:, errors:, results:, total_duration:)
        @total = total
        @passed = passed
        @failed = failed
        @errors = errors
        @results = results
        @total_duration = total_duration
      end

      def success?
        failed.zero? && errors.zero?
      end

      def summary
        {
          total: total,
          passed: passed,
          failed: failed,
          errors: errors,
          success_rate: (passed.to_f / total * 100).round(2),
          total_duration: total_duration.round(2)
        }
      end

      def failed_results
        results.select(&:failed?)
      end

      def error_results
        results.select(&:error?)
      end
    end
  end
end
