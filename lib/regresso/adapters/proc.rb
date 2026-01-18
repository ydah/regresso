# frozen_string_literal: true

module Regresso
  module Adapters
    # Adapter that calls a provided Proc or block for data.
    class Proc < Base
      # @param callable [Proc,nil]
      # @param description [String]
      def initialize(callable = nil, description: "Custom source", &block)
        super()
        @callable = callable || block
        @description_text = description
      end

      # Executes the callable and returns its value.
      #
      # @return [Object]
      def fetch
        raise ArgumentError, "callable is required" unless @callable

        @callable.call
      end

      # @return [String]
      def description
        @description_text
      end
    end
  end
end
