# frozen_string_literal: true

require "json"
require "fileutils"

module Regresso
  class SnapshotManager
    DEFAULT_DIR = "spec/snapshots/regresso"

    def initialize(base_dir: nil)
      @base_dir = base_dir || DEFAULT_DIR
    end

    def path_for(name)
      File.join(@base_dir, "#{name}.json")
    end

    def save(name, data)
      path = path_for(name)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, JSON.pretty_generate(data))
    end

    def load(name)
      JSON.parse(File.read(path_for(name)))
    end

    def exists?(name)
      File.exist?(path_for(name))
    end

    def delete(name)
      FileUtils.rm_f(path_for(name))
    end

    def list
      Dir.glob(File.join(@base_dir, "*.json")).map do |path|
        File.basename(path, ".json")
      end
    end
  end
end
