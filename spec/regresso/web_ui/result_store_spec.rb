# frozen_string_literal: true

require "regresso/web_ui"
require "tmpdir"

RSpec.describe Regresso::WebUI::ResultStore do
  it "stores and retrieves results" do
    Dir.mktmpdir do |dir|
      store = described_class.new(storage_path: dir)
      id = store.store({ "name" => "Run", "summary" => { "passed" => true } })
      data = store.find(id)

      expect(data["name"]).to eq("Run")
    end
  end

  it "lists results in reverse chronological order" do
    Dir.mktmpdir do |dir|
      store = described_class.new(storage_path: dir)
      first = store.store({ "name" => "First" })
      sleep 0.01
      second = store.store({ "name" => "Second" })

      list = store.list
      expect(list.first["id"]).to eq(second)
      expect(list.last["id"]).to eq(first)
    end
  end

  it "deletes results" do
    Dir.mktmpdir do |dir|
      store = described_class.new(storage_path: dir)
      id = store.store({ "name" => "Run" })
      store.delete(id)
      expect(store.find(id)).to be_nil
    end
  end
end
