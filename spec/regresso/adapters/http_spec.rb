# frozen_string_literal: true

require "regresso"
require "webmock/rspec"

RSpec.describe Regresso::Adapters::Http do
  let(:base_url) { "https://example.com" }

  it "performs a GET request" do
    stub_request(:get, "#{base_url}/data")
      .to_return(status: 200, body: { value: 1 }.to_json, headers: { "Content-Type" => "application/json" })

    adapter = described_class.new(base_url: base_url, endpoint: "/data")
    expect(adapter.fetch).to eq({ "value" => 1 })
  end

  it "performs a POST request" do
    stub_request(:post, "#{base_url}/submit")
      .to_return(status: 200, body: { ok: true }.to_json, headers: { "Content-Type" => "application/json" })

    adapter = described_class.new(base_url: base_url, endpoint: "/submit", method: :post)
    expect(adapter.fetch).to eq({ "ok" => true })
  end

  it "sends params and headers" do
    stub_request(:get, "#{base_url}/data")
      .with(query: { "q" => "test" }, headers: { "X-Token" => "secret" })
      .to_return(status: 200, body: { ok: true }.to_json, headers: { "Content-Type" => "application/json" })

    adapter = described_class.new(
      base_url: base_url,
      endpoint: "/data",
      params: { q: "test" },
      headers: { "X-Token" => "secret" }
    )

    expect(adapter.fetch).to eq({ "ok" => true })
  end

  it "raises on error status" do
    stub_request(:get, "#{base_url}/fail")
      .to_return(status: 500, body: "error")

    adapter = described_class.new(base_url: base_url, endpoint: "/fail")
    expect { adapter.fetch }.to raise_error(Regresso::Error)
  end
end
