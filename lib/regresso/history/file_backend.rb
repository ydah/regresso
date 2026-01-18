# frozen_string_literal: true

require "json"
require "fileutils"

module Regresso
  module History
    # File-backed persistence for {Regresso::History::Entry}.
    class FileBackend
      # @param storage_dir [String]
      def initialize(storage_dir: "tmp/regresso_history")
        @storage_dir = storage_dir
        FileUtils.mkdir_p(@storage_dir)
      end

      # @param entry [Regresso::History::Entry]
      # @return [void]
      def save(entry)
        File.write(path_for(entry.id), JSON.generate(entry.to_h))
      end

      # @param id [String]
      # @return [Regresso::History::Entry,nil]
      def find(id)
        path = path_for(id)
        return nil unless File.exist?(path)

        Entry.from_h(JSON.parse(File.read(path)))
      end

      # @return [Array<Regresso::History::Entry>]
      def all
        Dir.glob(File.join(@storage_dir, "*.json")).map do |path|
          Entry.from_h(JSON.parse(File.read(path)))
        end.sort_by(&:timestamp).reverse
      end

      # @param id [String]
      # @return [void]
      def delete(id)
        FileUtils.rm_f(path_for(id))
      end

      private

      def path_for(id)
        File.join(@storage_dir, "#{id}.json")
      end
    end
  end
end
