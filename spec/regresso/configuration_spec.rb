# frozen_string_literal: true

require "regresso"

RSpec.describe Regresso::Configuration do
  it "has default values" do
    config = described_class.new
    expect(config.default_tolerance).to eq(0.0)
    expect(config.ignore_paths).to eq([])
    expect(config.tolerance_overrides).to eq({})
    expect(config.array_order_sensitive).to be(true)
    expect(config.type_coercion).to be(true)
  end

  it "uses default tolerance when no override exists" do
    config = described_class.new
    config.default_tolerance = 0.5
    expect(config.tolerance_for(Regresso::JsonPath.root / "value")).to eq(0.5)
  end

  it "uses per-path tolerance overrides" do
    config = described_class.new
    config.tolerance_overrides["$.amount"] = 0.01
    expect(config.tolerance_for(Regresso::JsonPath.root / "amount")).to eq(0.01)
  end

  it "matches ignored paths by string" do
    config = described_class.new
    config.ignore_paths = ["$.ignored"]
    expect(config.ignored?(Regresso::JsonPath.root / "ignored")).to be(true)
  end

  it "matches ignored paths by regexp" do
    config = described_class.new
    config.ignore_paths = [/\.id$/]
    expect(config.ignored?(Regresso::JsonPath.root / "user" / "id")).to be(true)
  end

  it "merges configuration values" do
    base = described_class.new
    base.ignore_paths = ["$.base"]
    base.tolerance_overrides = { "$.amount" => 0.1 }
    base.array_order_sensitive = true
    base.type_coercion = false

    other = described_class.new
    other.default_tolerance = 0.2
    other.ignore_paths = ["$.other"]
    other.tolerance_overrides = { "$.total" => 0.3 }
    other.array_order_sensitive = false
    other.type_coercion = true

    merged = base.merge(other)

    expect(merged.default_tolerance).to eq(0.2)
    expect(merged.ignore_paths).to eq(["$.base", "$.other"])
    expect(merged.tolerance_overrides).to eq({ "$.amount" => 0.1, "$.total" => 0.3 })
    expect(merged.array_order_sensitive).to be(false)
    expect(merged.type_coercion).to be(true)
  end
end
