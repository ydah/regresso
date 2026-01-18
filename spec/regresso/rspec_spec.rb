# frozen_string_literal: true

require "regresso/rspec"
require "tmpdir"

RSpec.describe "Regresso RSpec matchers" do
  it "supports have_no_regression_from" do
    source_a = { value: 1 }
    source_b = { value: 1 }

    expect(source_b).to have_no_regression_from(source_a)
  end

  it "provides a helpful failure message" do
    source_a = { value: 1 }
    source_b = { value: 2 }

    expect do
      expect(source_b).to have_no_regression_from(source_a)
    end.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Expected no regression/)
  end

  it "supports match_snapshot" do
    Dir.mktmpdir do |dir|
      manager = Regresso::SnapshotManager.new(base_dir: dir)
      allow(Regresso::SnapshotManager).to receive(:new).and_return(manager)

      expect({ "value" => 1 }).to match_snapshot("example")
      expect({ "value" => 1 }).to match_snapshot("example")
    end
  end
end
