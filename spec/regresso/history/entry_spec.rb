# frozen_string_literal: true

require "regresso/history"

RSpec.describe Regresso::History::Entry do
  it "serializes and deserializes" do
    entry = described_class.new(
      id: "1",
      timestamp: Time.now,
      result: { success: true },
      metadata: { "error" => nil }
    )

    hash = entry.to_h
    restored = described_class.from_h(hash)

    expect(restored.id).to eq("1")
    expect(restored.result["success"]).to be(true)
  end

  it "detects pass/fail" do
    passed = described_class.new(id: "1", timestamp: Time.now, result: { success: true })
    failed = described_class.new(id: "2", timestamp: Time.now, result: { success: false })

    expect(passed.passed?).to be(true)
    expect(failed.failed?).to be(true)
  end
end
