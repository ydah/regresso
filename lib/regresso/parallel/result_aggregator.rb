# frozen_string_literal: true

module Regresso
  module Parallel
    class ResultAggregator
      def initialize(results)
        @results = results
      end

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
