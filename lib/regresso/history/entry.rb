# frozen_string_literal: true

module Regresso
  module History
    class Entry
      attr_reader :id, :timestamp, :result, :metadata

      def initialize(id:, timestamp:, result:, metadata: {})
        @id = id
        @timestamp = timestamp
        @result = result
        @metadata = metadata
      end

      def passed?
        value = result[:success]
        value = result["success"] if value.nil?
        !!value
      end

      def failed?
        !passed?
      end

      def to_h
        {
          "id" => id,
          "timestamp" => timestamp.iso8601,
          "result" => result,
          "metadata" => metadata
        }
      end

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
