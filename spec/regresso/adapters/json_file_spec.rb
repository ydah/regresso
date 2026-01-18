# frozen_string_literal: true

require "regresso"

RSpec.describe Regresso::Adapters::JsonFile do
  let(:fixture_path) { File.expand_path("../../fixtures/sample.json", __dir__) }

  it "reads JSON from a file" do
    adapter = described_class.new(path: fixture_path)
    expect(adapter.fetch).to eq({ "name" => "Alice", "age" => 30 })
  end

  it "raises when the file does not exist" do
    adapter = described_class.new(path: "missing.json")
    expect { adapter.fetch }.to raise_error(Errno::ENOENT)
  end

  it "raises on invalid JSON" do
    path = File.expand_path("../../fixtures/invalid.json", __dir__)
    File.write(path, "{invalid")

    adapter = described_class.new(path: path)
    expect { adapter.fetch }.to raise_error(JSON::ParserError)
  ensure
    File.delete(path) if File.exist?(path)
  end
end
