# frozen_string_literal: true

module Regresso
  # Persistent storage structures for historical comparisons.
  module History
    # A stored snapshot of a single comparison result.
    class Entry
      # @return [String]
      attr_reader :id

      # @return [Time]
      attr_reader :timestamp

      # @return [Hash]
      attr_reader :result

      # @return [Hash]
      attr_reader :metadata

      # @param id [String]
      # @param timestamp [Time]
      # @param result [Hash]
      # @param metadata [Hash]
      def initialize(id:, timestamp:, result:, metadata: {})
        @id = id
        @timestamp = timestamp
        @result = result
        @metadata = metadata
      end

      # @return [Boolean]
      def passed?
        value = result[:success]
        value = result["success"] if value.nil?
        !!value
      end

      # @return [Boolean]
      def failed?
        !passed?
      end

      # @return [Hash]
      def to_h
        {
          "id" => id,
          "timestamp" => timestamp.iso8601,
          "result" => result,
          "metadata" => metadata
        }
      end

      # @param hash [Hash]
      # @return [Regresso::History::Entry]
      def self.from_h(hash)
        source = hash.transform_keys(&:to_s)
        result = source["result"] || {}
        result = result.transform_keys(&:to_s) if result.respond_to?(:transform_keys)
        metadata = source["metadata"] || {}
        metadata = metadata.transform_keys(&:to_s) if metadata.respond_to?(:transform_keys)
        new(
          id: source["id"] || hash[:id],
          timestamp: Time.parse(source["timestamp"] || hash[:timestamp].to_s),
          result: result,
          metadata: metadata
        )
      end
    end
  end
end
