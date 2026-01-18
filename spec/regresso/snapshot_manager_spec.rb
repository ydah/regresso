# frozen_string_literal: true

require "regresso/snapshot_manager"
require "tmpdir"

RSpec.describe Regresso::SnapshotManager do
  it "saves and loads snapshots" do
    Dir.mktmpdir do |dir|
      manager = described_class.new(base_dir: dir)
      manager.save("example", { "value" => 1 })
      expect(manager.load("example")).to eq({ "value" => 1 })
    end
  end

  it "checks existence" do
    Dir.mktmpdir do |dir|
      manager = described_class.new(base_dir: dir)
      expect(manager.exists?("missing")).to be(false)
      manager.save("present", { "value" => 1 })
      expect(manager.exists?("present")).to be(true)
    end
  end

  it "deletes snapshots" do
    Dir.mktmpdir do |dir|
      manager = described_class.new(base_dir: dir)
      manager.save("example", { "value" => 1 })
      manager.delete("example")
      expect(manager.exists?("example")).to be(false)
    end
  end

  it "lists snapshots" do
    Dir.mktmpdir do |dir|
      manager = described_class.new(base_dir: dir)
      manager.save("one", { "value" => 1 })
      manager.save("two", { "value" => 2 })
      expect(manager.list.sort).to eq(["one", "two"])
    end
  end
end
