# frozen_string_literal: true

require "regresso"

RSpec.describe Regresso::Adapters::Proc do
  it "initializes with a callable" do
    adapter = described_class.new(-> { 1 })
    expect(adapter.fetch).to eq(1)
  end

  it "initializes with a block" do
    adapter = described_class.new { "value" }
    expect(adapter.fetch).to eq("value")
  end

  it "allows custom description" do
    adapter = described_class.new(-> { 1 }, description: "custom")
    expect(adapter.description).to eq("custom")
  end

  it "raises when callable is missing" do
    adapter = described_class.new(nil)
    expect { adapter.fetch }.to raise_error(ArgumentError)
  end
end
