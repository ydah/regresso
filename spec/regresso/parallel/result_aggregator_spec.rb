# frozen_string_literal: true

require "regresso/parallel"

RSpec.describe Regresso::Parallel::ResultAggregator do
  it "aggregates empty results" do
    aggregator = described_class.new([])
    result = aggregator.aggregate

    expect(result.total).to eq(0)
    expect(result.passed).to eq(0)
    expect(result.failed).to eq(0)
    expect(result.errors).to eq(0)
    expect(result.total_duration).to eq(0)
  end

  it "aggregates mixed results" do
    passed = instance_double(Regresso::Parallel::ComparisonResult, passed?: true, failed?: false, error?: false, duration: 1.0)
    failed = instance_double(Regresso::Parallel::ComparisonResult, passed?: false, failed?: true, error?: false, duration: 2.0)
    error = instance_double(Regresso::Parallel::ComparisonResult, passed?: false, failed?: false, error?: true, duration: 3.0)

    aggregator = described_class.new([passed, failed, error])
    result = aggregator.aggregate

    expect(result.total).to eq(3)
    expect(result.passed).to eq(1)
    expect(result.failed).to eq(1)
    expect(result.errors).to eq(1)
    expect(result.total_duration).to eq(6.0)
  end
end
