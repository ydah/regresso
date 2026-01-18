# frozen_string_literal: true

require "regresso/parallel"

RSpec.describe Regresso::Parallel::ComparisonResult do
  it "detects passed results" do
    result = instance_double(Regresso::Result, passed?: true, failed?: false)
    comparison = described_class.new(name: "test", result: result, duration: 1.0)
    expect(comparison.passed?).to be(true)
    expect(comparison.failed?).to be(false)
    expect(comparison.error?).to be(false)
    expect(comparison.status).to eq(:passed)
  end

  it "detects failed results" do
    result = instance_double(Regresso::Result, passed?: false, failed?: true)
    comparison = described_class.new(name: "test", result: result, duration: 1.0)
    expect(comparison.passed?).to be(false)
    expect(comparison.failed?).to be(true)
    expect(comparison.error?).to be(false)
    expect(comparison.status).to eq(:failed)
  end

  it "detects error results" do
    comparison = described_class.new(name: "test", error: StandardError.new("boom"), duration: 1.0)
    expect(comparison.passed?).to be(false)
    expect(comparison.failed?).to be(false)
    expect(comparison.error?).to be(true)
    expect(comparison.status).to eq(:error)
  end

  it "stores duration" do
    comparison = described_class.new(name: "test", duration: 0.5)
    expect(comparison.duration).to eq(0.5)
  end
end
