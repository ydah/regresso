# frozen_string_literal: true

module Regresso
  # Parallel execution utilities for multiple comparisons.
  module Parallel
    # Executes multiple comparisons concurrently.
    class Runner
      # Default number of worker threads.
      DEFAULT_WORKERS = 4

      # @param comparisons [Array<Hash>]
      # @param workers [Integer]
      # @param config [Regresso::Configuration]
      def initialize(comparisons:, workers: DEFAULT_WORKERS, config: Configuration.new)
        @comparisons = comparisons
        @workers = workers
        @config = config
      end

      # @return [Regresso::Parallel::ParallelResult]
      def run
        results = execute_parallel
        ResultAggregator.new(results).aggregate
      end

      private

      def execute_parallel
        queue = Queue.new
        @comparisons.each { |comparison| queue << comparison }

        threads = @workers.times.map do
          Thread.new do
            thread_results = []
            loop do
              comparison = queue.pop(true) rescue nil
              break unless comparison

              thread_results << execute_comparison(comparison)
            end
            thread_results
          end
        end

        threads.flat_map(&:value)
      end

      def execute_comparison(comparison)
        start_time = Time.now
        comparator = Comparator.new(
          source_a: comparison[:source_a],
          source_b: comparison[:source_b],
          config: @config
        )
        result = comparator.compare

        ComparisonResult.new(
          name: comparison[:name],
          result: result,
          duration: Time.now - start_time
        )
      rescue StandardError => e
        ComparisonResult.new(
          name: comparison[:name],
          error: e,
          duration: Time.now - start_time
        )
      end
    end
  end
end
