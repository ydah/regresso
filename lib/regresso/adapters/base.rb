# frozen_string_literal: true

module Regresso
  module Adapters
    class Base
      attr_reader :options

      def initialize(**options)
        @options = options
      end

      def fetch
        raise NotImplementedError, "Adapters must implement #fetch"
      end

      def description
        raise NotImplementedError, "Adapters must implement #description"
      end
    end
  end
end
