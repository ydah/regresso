# frozen_string_literal: true

require "json"

module Regresso
  module Adapters
    # Adapter that loads JSON content from a file.
    class JsonFile < Base
      # @param path [String]
      def initialize(path:)
        super()
        @path = path
      end

      # Loads JSON from the file.
      #
      # @return [Object]
      def fetch
        raise Errno::ENOENT, @path unless File.exist?(@path)

        JSON.parse(File.read(@path))
      end

      # @return [String]
      def description
        "JSON File: #{@path}"
      end
    end
  end
end
