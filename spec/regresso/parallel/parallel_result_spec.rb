# frozen_string_literal: true

require "regresso/parallel"

RSpec.describe Regresso::Parallel::ParallelResult do
  let(:passed_result) { instance_double(Regresso::Parallel::ComparisonResult, passed?: true, failed?: false, error?: false, duration: 1.0) }
  let(:failed_result) { instance_double(Regresso::Parallel::ComparisonResult, passed?: false, failed?: true, error?: false, duration: 2.0) }
  let(:error_result) { instance_double(Regresso::Parallel::ComparisonResult, passed?: false, failed?: false, error?: true, duration: 3.0) }

  it "detects overall success" do
    result = described_class.new(
      total: 2,
      passed: 2,
      failed: 0,
      errors: 0,
      results: [passed_result, passed_result],
      total_duration: 2.0
    )

    expect(result.success?).to be(true)
  end

  it "returns summary hash" do
    result = described_class.new(
      total: 2,
      passed: 1,
      failed: 1,
      errors: 0,
      results: [passed_result, failed_result],
      total_duration: 3.5
    )

    summary = result.summary
    expect(summary[:total]).to eq(2)
    expect(summary[:passed]).to eq(1)
    expect(summary[:failed]).to eq(1)
    expect(summary[:errors]).to eq(0)
  end

  it "filters failed and error results" do
    result = described_class.new(
      total: 3,
      passed: 1,
      failed: 1,
      errors: 1,
      results: [passed_result, failed_result, error_result],
      total_duration: 6.0
    )

    expect(result.failed_results).to eq([failed_result])
    expect(result.error_results).to eq([error_result])
  end
end
