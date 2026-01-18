# frozen_string_literal: true

require "regresso"

RSpec.describe Regresso::JsonPath do
  describe ".root" do
    it "returns the root path" do
      expect(described_class.root.to_s).to eq("$")
    end
  end

  describe "#/" do
    it "appends segments" do
      path = described_class.root / "users" / "name"
      expect(path.to_s).to eq("$.users.name")
    end

    it "handles array indexes" do
      path = described_class.root / 0 / "item"
      expect(path.to_s).to eq("$[0].item")
    end
  end

  describe "#==" do
    it "compares based on string representation" do
      a = described_class.root / "users" / 1
      b = described_class.root / "users" / 1
      expect(a).to eq(b)
    end
  end
end
