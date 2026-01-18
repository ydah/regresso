# frozen_string_literal: true

require "json"
require "fileutils"

module Regresso
  class SnapshotManager
    DEFAULT_DIR = "spec/snapshots/regresso"

    # @param base_dir [String,nil]
    def initialize(base_dir: nil)
      @base_dir = base_dir || DEFAULT_DIR
    end

    # @param name [String]
    # @return [String]
    def path_for(name)
      File.join(@base_dir, "#{name}.json")
    end

    # @param name [String]
    # @param data [Object]
    # @return [void]
    def save(name, data)
      path = path_for(name)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, JSON.pretty_generate(data))
    end

    # @param name [String]
    # @return [Object]
    def load(name)
      JSON.parse(File.read(path_for(name)))
    end

    # @param name [String]
    # @return [Boolean]
    def exists?(name)
      File.exist?(path_for(name))
    end

    # @param name [String]
    # @return [void]
    def delete(name)
      FileUtils.rm_f(path_for(name))
    end

    # @return [Array<String>]
    def list
      Dir.glob(File.join(@base_dir, "*.json")).map do |path|
        File.basename(path, ".json")
      end
    end
  end
end
