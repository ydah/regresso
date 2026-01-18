# frozen_string_literal: true

module Regresso
  module History
    class Statistics
      def initialize(entries)
        @entries = entries
      end

      def calculate
        {
          total_runs: @entries.size,
          success_rate: calculate_success_rate,
          average_duration: calculate_average_duration,
          failure_trend: calculate_failure_trend,
          common_failures: identify_common_failures,
          by_day: aggregate_by_day
        }
      end

      private

      def calculate_success_rate
        return 0.0 if @entries.empty?

        passed = @entries.count(&:passed?)
        (passed.to_f / @entries.size * 100).round(2)
      end

      def calculate_average_duration
        return 0.0 if @entries.empty?

        total = @entries.sum { |entry| entry.result[:duration].to_f }
        (total / @entries.size).round(2)
      end

      def calculate_failure_trend
        @entries.group_by { |entry| entry.timestamp.to_date }
                .transform_values { |list| list.count(&:failed?) }
      end

      def identify_common_failures
        failures = @entries.select(&:failed?)
        failures.group_by { |entry| entry.metadata["error"] || "unknown" }
                .transform_values(&:size)
                .sort_by { |_key, value| -value }
                .to_h
      end

      def aggregate_by_day
        @entries.group_by { |entry| entry.timestamp.to_date }
                .transform_values do |list|
          {
            total: list.size,
            passed: list.count(&:passed?),
            failed: list.count(&:failed?)
          }
        end
      end
    end
  end
end
