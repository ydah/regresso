# frozen_string_literal: true

module Regresso
  module Parallel
    # Result wrapper for a single comparison execution.
    class ComparisonResult
      # @return [String]
      attr_reader :name

      # @return [Regresso::Result,nil]
      attr_reader :result

      # @return [StandardError,nil]
      attr_reader :error

      # @return [Float]
      attr_reader :duration

      # @param name [String]
      # @param result [Regresso::Result,nil]
      # @param error [StandardError,nil]
      # @param duration [Float]
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

      # @return [Symbol] :passed, :failed, or :error
      def status
        return :error if error?
        return :passed if passed?

        :failed
      end
    end
  end
end
