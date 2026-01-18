# frozen_string_literal: true

require "regresso"

RSpec.describe Regresso::Comparator do
  class TestSource
    def initialize(data)
      @data = data
    end

    def fetch
      @data
    end
  end

  it "compares two sources" do
    source_a = TestSource.new({ "value" => 1 })
    source_b = TestSource.new({ "value" => 2 })

    result = described_class.new(source_a: source_a, source_b: source_b).compare

    expect(result).to be_a(Regresso::Result)
    expect(result.passed?).to be(false)
  end

  it "applies configuration settings" do
    config = Regresso::Configuration.new
    config.default_tolerance = 1.0

    source_a = TestSource.new({ "value" => 1.0 })
    source_b = TestSource.new({ "value" => 1.5 })

    result = described_class.new(source_a: source_a, source_b: source_b, config: config).compare

    expect(result.passed?).to be(true)
  end
end
