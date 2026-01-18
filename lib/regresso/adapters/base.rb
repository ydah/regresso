# frozen_string_literal: true

module Regresso
  module Adapters
    class Base
      attr_reader :options

      # @param options [Hash]
      def initialize(**options)
        @options = options
      end

      # Fetches data from the source.
      #
      # @return [Object]
      def fetch
        raise NotImplementedError, "Adapters must implement #fetch"
      end

      # Returns a short description of the source.
      #
      # @return [String]
      def description
        raise NotImplementedError, "Adapters must implement #description"
      end
    end
  end
end
