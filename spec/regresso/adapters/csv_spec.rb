# frozen_string_literal: true

require "regresso"

RSpec.describe Regresso::Adapters::Csv do
  let(:fixture_path) { File.expand_path("../../fixtures/sample.csv", __dir__) }

  it "reads CSV from a file" do
    adapter = described_class.new(path: fixture_path)
    expect(adapter.fetch).to eq([
      { "name" => "Alice", "age" => "30" },
      { "name" => "Bob", "age" => "25" }
    ])
  end

  it "reads CSV from inline content" do
    content = "name,age\nAlice,30\n"
    adapter = described_class.new(content: content)
    expect(adapter.fetch).to eq([{ "name" => "Alice", "age" => "30" }])
  end

  it "supports headers disabled" do
    content = "a,b\nc,d\n"
    adapter = described_class.new(content: content, headers: false)
    expect(adapter.fetch).to eq([
      { "0" => "a", "1" => "b" },
      { "0" => "c", "1" => "d" }
    ])
  end

  it "supports custom column separators" do
    content = "name|age\nAlice|30\n"
    adapter = described_class.new(content: content, col_sep: "|")
    expect(adapter.fetch).to eq([{ "name" => "Alice", "age" => "30" }])
  end
end
