# frozen_string_literal: true

require "regresso"

RSpec.describe Regresso::Result do
  let(:config) { Regresso::Configuration.new }
  let(:path) { Regresso::JsonPath.root / "value" }

  it "passes when there are no diffs" do
    result = described_class.new(source_a: :a, source_b: :b, diffs: [], config: config)
    expect(result.passed?).to be(true)
    expect(result.failed?).to be(false)
  end

  it "fails when there are diffs" do
    diff = Regresso::Difference.new(path: path, old_value: 1, new_value: 2)
    result = described_class.new(source_a: :a, source_b: :b, diffs: [diff], config: config)
    expect(result.passed?).to be(false)
    expect(result.failed?).to be(true)
  end

  it "filters out ignored diffs" do
    config.ignore_paths = ["$.value"]
    diff = Regresso::Difference.new(path: path, old_value: 1, new_value: 2)
    result = described_class.new(source_a: :a, source_b: :b, diffs: [diff], config: config)
    expect(result.meaningful_diffs).to eq([])
  end

  it "returns a summary hash" do
    diff = Regresso::Difference.new(path: path, old_value: 1, new_value: 2)
    result = described_class.new(source_a: :a, source_b: :b, diffs: [diff], config: config)
    expect(result.summary).to eq(
      {
        total_diffs: 1,
        meaningful_diffs: 1,
        ignored_diffs: 0,
        passed: false
      }
    )
  end
end
