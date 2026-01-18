# frozen_string_literal: true

require "regresso/history"
require "tmpdir"

RSpec.describe Regresso::History::FileBackend do
  it "persists entries" do
    Dir.mktmpdir do |dir|
      backend = described_class.new(storage_dir: dir)
      entry = Regresso::History::Entry.new(id: "1", timestamp: Time.now, result: { success: true })
      backend.save(entry)

      loaded = backend.find("1")
      expect(loaded.id).to eq("1")
    end
  end

  it "lists entries in reverse order" do
    Dir.mktmpdir do |dir|
      backend = described_class.new(storage_dir: dir)
      entry1 = Regresso::History::Entry.new(id: "1", timestamp: Time.now - 10, result: { success: true })
      entry2 = Regresso::History::Entry.new(id: "2", timestamp: Time.now, result: { success: false })
      backend.save(entry1)
      backend.save(entry2)

      list = backend.all
      expect(list.first.id).to eq("2")
    end
  end
end
