# frozen_string_literal: true

require "regresso/ci"

RSpec.describe Regresso::CI::Reporter do
  let(:comparison) { instance_double(Regresso::Parallel::ComparisonResult, name: "ok", status: :passed, duration: 1.0, failed?: false, error?: false, error: nil) }
  let(:parallel_result) do
    instance_double(
      Regresso::Parallel::ParallelResult,
      total: 1,
      passed: 1,
      failed: 0,
      errors: 0,
      results: [comparison]
    )
  end

  it "outputs junit xml" do
    reporter = described_class.new(parallel_result)
    expect(reporter.to_junit_xml).to include("<testsuites")
  end

  it "outputs github annotations" do
    reporter = described_class.new(parallel_result)
    expect(reporter.to_github_annotations).to eq([])
  end

  it "outputs gitlab report" do
    reporter = described_class.new(parallel_result)
    report = reporter.to_gitlab_report
    expect(report[:total]).to eq(1)
    expect(report[:results].first[:status]).to eq(:passed)
  end
end
