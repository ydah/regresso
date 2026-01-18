# frozen_string_literal: true

module Regresso
  module Adapters
    class Proc < Base
      def initialize(callable = nil, description: "Custom source", &block)
        super()
        @callable = callable || block
        @description_text = description
      end

      def fetch
        raise ArgumentError, "callable is required" unless @callable

        @callable.call
      end

      def description
        @description_text
      end
    end
  end
end
