# frozen_string_literal: true

require "regresso/ci"

RSpec.describe Regresso::CI::JUnitXmlFormatter do
  let(:passed_result) { instance_double(Regresso::Parallel::ComparisonResult, name: "ok", passed?: true, failed?: false, error?: false, duration: 1.0) }
  let(:failed_result) { instance_double(Regresso::Parallel::ComparisonResult, name: "fail", passed?: false, failed?: true, error?: false, duration: 2.0) }
  let(:error_obj) { StandardError.new("boom") }
  let(:error_result) { instance_double(Regresso::Parallel::ComparisonResult, name: "error", passed?: false, failed?: false, error?: true, duration: 3.0, error: error_obj) }

  let(:parallel_result) do
    instance_double(
      Regresso::Parallel::ParallelResult,
      total: 3,
      failed: 1,
      errors: 1,
      results: [passed_result, failed_result, error_result]
    )
  end

  it "generates valid junit xml" do
    xml = described_class.new(parallel_result).format
    expect(xml).to include("<testsuites")
    expect(xml).to include("<testcase")
    expect(xml).to include("<failure")
    expect(xml).to include("<error")
  end
end
