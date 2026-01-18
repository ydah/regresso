# frozen_string_literal: true

module Regresso
  module Parallel
    # Summary of multiple comparison results.
    class ParallelResult
      # @return [Integer]
      attr_reader :total

      # @return [Integer]
      attr_reader :passed

      # @return [Integer]
      attr_reader :failed

      # @return [Integer]
      attr_reader :errors

      # @return [Array<Regresso::Parallel::ComparisonResult>]
      attr_reader :results

      # @return [Float]
      attr_reader :total_duration

      # @param total [Integer]
      # @param passed [Integer]
      # @param failed [Integer]
      # @param errors [Integer]
      # @param results [Array<Regresso::Parallel::ComparisonResult>]
      # @param total_duration [Float]
      def initialize(total:, passed:, failed:, errors:, results:, total_duration:)
        @total = total
        @passed = passed
        @failed = failed
        @errors = errors
        @results = results
        @total_duration = total_duration
      end

      # @return [Boolean]
      def success?
        failed.zero? && errors.zero?
      end

      # @return [Hash]
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

      # @return [Array<Regresso::Parallel::ComparisonResult>]
      def failed_results
        results.select(&:failed?)
      end

      # @return [Array<Regresso::Parallel::ComparisonResult>]
      def error_results
        results.select(&:error?)
      end
    end
  end
end
