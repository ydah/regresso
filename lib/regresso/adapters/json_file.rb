# frozen_string_literal: true

require "json"

module Regresso
  module Adapters
    class JsonFile < Base
      def initialize(path:)
        super()
        @path = path
      end

      def fetch
        raise Errno::ENOENT, @path unless File.exist?(@path)

        JSON.parse(File.read(@path))
      end

      def description
        "JSON File: #{@path}"
      end
    end
  end
end
