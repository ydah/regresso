# frozen_string_literal: true

require "regresso"
require "regresso/reporter"

RSpec.describe Regresso::Reporter do
  let(:config) { Regresso::Configuration.new }
  let(:path) { Regresso::JsonPath.root / "value" }
  let(:diff) { Regresso::Difference.new(path: path, old_value: 1, new_value: 2) }
  let(:result) { Regresso::Result.new(source_a: :a, source_b: :b, diffs: [diff], config: config) }

  it "generates text output" do
    output = described_class.new(result).generate(:text)
    expect(output).to include("Regresso Report")
    expect(output).to include("$.value: 1 -> 2")
  end

  it "generates json output" do
    output = described_class.new(result).generate(:json)
    parsed = JSON.parse(output)
    expect(parsed["summary"]["total_diffs"]).to eq(1)
    expect(parsed["diffs"].first["path"]).to eq("$.value")
  end

  it "generates html output" do
    output = described_class.new(result).generate(:html)
    expect(output).to include("<html")
    expect(output).to include("$.value")
  end

  it "raises on unknown format" do
    expect { described_class.new(result).generate(:xml) }.to raise_error(ArgumentError)
  end
end
