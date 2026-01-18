# frozen_string_literal: true

module Regresso
  module Parallel
    class ComparisonResult
      attr_reader :name, :result, :error, :duration

      def initialize(name:, result: nil, error: nil, duration:)
        @name = name
        @result = result
        @error = error
        @duration = duration
      end

      def passed?
        error.nil? && result&.passed?
      end

      def failed?
        error.nil? && result&.failed?
      end

      def error?
        !error.nil?
      end

      def status
        return :error if error?
        return :passed if passed?

        :failed
      end
    end
  end
end
