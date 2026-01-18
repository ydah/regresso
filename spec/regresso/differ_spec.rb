# frozen_string_literal: true

require "regresso"

RSpec.describe Regresso::Differ do
  let(:config) { Regresso::Configuration.new }
  let(:differ) { described_class.new(config) }

  it "returns no diffs for identical data" do
    data = { "a" => 1, "b" => [1, 2] }
    expect(differ.diff(data, data)).to eq([])
  end

  it "detects primitive value differences" do
    diffs = differ.diff(1, 2)
    expect(diffs.size).to eq(1)
    expect(diffs.first.path.to_s).to eq("$")
  end

  it "detects nested hash differences" do
    a = { "user" => { "name" => "Alice" } }
    b = { "user" => { "name" => "Bob" } }
    diffs = differ.diff(a, b)
    expect(diffs.size).to eq(1)
    expect(diffs.first.path.to_s).to eq("$.user.name")
  end

  it "detects array differences" do
    diffs = differ.diff([1, 2], [1, 3])
    expect(diffs.size).to eq(1)
    expect(diffs.first.path.to_s).to eq("$[1]")
  end

  it "respects numeric tolerance" do
    config.default_tolerance = 0.1
    diffs = differ.diff(1.0, 1.05)
    expect(diffs).to eq([])
  end

  it "ignores configured paths" do
    config.ignore_paths = ["$.user.id"]
    a = { "user" => { "id" => 1 } }
    b = { "user" => { "id" => 2 } }
    expect(differ.diff(a, b)).to eq([])
  end

  it "supports order-insensitive array comparison" do
    config.array_order_sensitive = false
    diffs = differ.diff([1, 2], [2, 1])
    expect(diffs).to eq([])
  end

  it "coerces numeric strings when enabled" do
    config.type_coercion = true
    diffs = differ.diff("1.0", 1.0)
    expect(diffs).to eq([])
  end

  it "does not coerce numeric strings when disabled" do
    config.type_coercion = false
    diffs = differ.diff("1.0", 1.0)
    expect(diffs.size).to eq(1)
  end
end
