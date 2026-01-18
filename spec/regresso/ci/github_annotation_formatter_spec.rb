# frozen_string_literal: true

require "regresso/ci"

RSpec.describe Regresso::CI::GitHubAnnotationFormatter do
  let(:failed_result) { instance_double(Regresso::Parallel::ComparisonResult, name: "fail", failed?: true, error?: false, error: nil) }
  let(:error_obj) { StandardError.new("boom") }
  let(:error_result) { instance_double(Regresso::Parallel::ComparisonResult, name: "error", failed?: false, error?: true, error: error_obj) }
  let(:passed_result) { instance_double(Regresso::Parallel::ComparisonResult, name: "ok", failed?: false, error?: false, error: nil) }

  let(:parallel_result) do
    instance_double(Regresso::Parallel::ParallelResult, results: [failed_result, error_result, passed_result])
  end

  it "builds annotations" do
    annotations = described_class.new(parallel_result).annotations
    expect(annotations.size).to eq(2)
    expect(annotations.first[:annotation_level]).to eq("error")
  end

  it "formats workflow output" do
    output = described_class.new(parallel_result).output_for_workflow
    expect(output).to include("::error")
  end
end
