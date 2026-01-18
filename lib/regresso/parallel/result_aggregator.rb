# frozen_string_literal: true

module Regresso
  module Parallel
    # Aggregates comparison results into a summary.
    class ResultAggregator
      # @param results [Array<Regresso::Parallel::ComparisonResult>]
      def initialize(results)
        @results = results
      end

      # @return [Regresso::Parallel::ParallelResult]
      def aggregate
        ParallelResult.new(
          total: @results.size,
          passed: @results.count(&:passed?),
          failed: @results.count(&:failed?),
          errors: @results.count(&:error?),
          results: @results,
          total_duration: @results.sum(&:duration)
        )
      end
    end
  end
end
