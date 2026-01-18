# frozen_string_literal: true

require "json"
require "fileutils"
require "securerandom"

module Regresso
  module WebUI
    class ResultStore
      def initialize(storage_path: nil)
        @storage_path = storage_path || "tmp/regresso_results"
        @cache = {}
        FileUtils.mkdir_p(@storage_path)
      end

      def store(result)
        id = SecureRandom.uuid
        data = { "id" => id, "created_at" => Time.now.iso8601 }.merge(result)
        File.write(path_for(id), JSON.generate(data))
        @cache[id] = data
        id
      end

      def find(id)
        return @cache[id] if @cache.key?(id)

        path = path_for(id)
        return nil unless File.exist?(path)

        @cache[id] = JSON.parse(File.read(path))
      end

      def list
        Dir.glob(File.join(@storage_path, "*.json")).map do |path|
          find(File.basename(path, ".json"))
        end.compact.sort_by { |entry| entry["created_at"] }.reverse
      end

      def delete(id)
        @cache.delete(id)
        FileUtils.rm_f(path_for(id))
      end

      private

      def path_for(id)
        File.join(@storage_path, "#{id}.json")
      end
    end
  end
end
