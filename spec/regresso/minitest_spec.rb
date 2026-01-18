# frozen_string_literal: true

require "regresso/minitest"
require "minitest"
require "minitest/assertions"
require "tmpdir"

RSpec.describe Regresso::Minitest::Assertions do
  class DummyMinitest
    include Minitest::Assertions
    include Regresso::Minitest::Assertions

    attr_accessor :assertions

    def initialize
      @assertions = 0
    end
  end

  it "asserts no regression" do
    dummy = DummyMinitest.new
    expect { dummy.assert_no_regression({ value: 1 }, { value: 1 }) }.not_to raise_error
  end

  it "raises on regression" do
    dummy = DummyMinitest.new
    expect { dummy.assert_no_regression({ value: 1 }, { value: 2 }) }
      .to raise_error(Minitest::Assertion)
  end

  it "handles snapshot assertions" do
    Dir.mktmpdir do |dir|
      manager = Regresso::SnapshotManager.new(base_dir: dir)
      allow(Regresso::SnapshotManager).to receive(:new).and_return(manager)

      dummy = DummyMinitest.new
      expect { dummy.assert_matches_snapshot({ "value" => 1 }, "example") }.not_to raise_error
      expect { dummy.assert_matches_snapshot({ "value" => 1 }, "example") }.not_to raise_error
    end
  end
end
