# frozen_string_literal: true

require "regresso/parallel"

RSpec.describe Regresso::Parallel::Runner do
  class TestSource
    def initialize(data)
      @data = data
    end

    def fetch
      @data
    end
  end

  it "runs comparisons in parallel" do
    comparisons = [
      { name: "a", source_a: TestSource.new({ "value" => 1 }), source_b: TestSource.new({ "value" => 1 }) },
      { name: "b", source_a: TestSource.new({ "value" => 1 }), source_b: TestSource.new({ "value" => 2 }) }
    ]

    result = described_class.new(comparisons: comparisons, workers: 2).run

    expect(result.total).to eq(2)
    expect(result.passed).to eq(1)
    expect(result.failed).to eq(1)
  end

  it "captures errors" do
    comparisons = [
      { name: "error", source_a: Object.new, source_b: Object.new }
    ]

    result = described_class.new(comparisons: comparisons, workers: 1).run

    expect(result.errors).to eq(1)
  end
end
