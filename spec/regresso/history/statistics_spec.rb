# frozen_string_literal: true

require "regresso/history"

RSpec.describe Regresso::History::Statistics do
  it "handles empty data" do
    stats = described_class.new([]).calculate
    expect(stats[:total_runs]).to eq(0)
    expect(stats[:success_rate]).to eq(0.0)
  end

  it "calculates statistics" do
    entries = [
      Regresso::History::Entry.new(id: "1", timestamp: Time.now, result: { success: true, duration: 1.0 }),
      Regresso::History::Entry.new(id: "2", timestamp: Time.now, result: { success: false, duration: 2.0 }, metadata: { "error" => "boom" })
    ]

    stats = described_class.new(entries).calculate
    expect(stats[:total_runs]).to eq(2)
    expect(stats[:success_rate]).to eq(50.0)
    expect(stats[:common_failures]["boom"]).to eq(1)
  end
end
