# frozen_string_literal: true

require "regresso"

RSpec.describe Regresso::Difference do
  let(:path) { Regresso::JsonPath.root / "value" }

  it "detects added values" do
    diff = described_class.new(path: path, old_value: nil, new_value: 1)
    expect(diff.type).to eq(:added)
  end

  it "detects removed values" do
    diff = described_class.new(path: path, old_value: 1, new_value: nil)
    expect(diff.type).to eq(:removed)
  end

  it "detects changed values" do
    diff = described_class.new(path: path, old_value: 1, new_value: 2)
    expect(diff.type).to eq(:changed)
  end

  it "formats a readable message" do
    diff = described_class.new(path: path, old_value: 1, new_value: 2)
    expect(diff.to_s).to eq("$.value: 1 -> 2")
  end
end
