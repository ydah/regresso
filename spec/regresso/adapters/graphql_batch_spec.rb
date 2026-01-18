# frozen_string_literal: true

require "regresso"
require "webmock/rspec"

RSpec.describe Regresso::Adapters::GraphQLBatch do
  let(:endpoint) { "https://example.com/graphql" }

  it "executes multiple queries" do
    stub_request(:post, endpoint)
      .with(body: { query: "query A { a }", variables: {} }.to_json)
      .to_return(status: 200, body: { data: { "a" => 1 } }.to_json, headers: { "Content-Type" => "application/json" })

    stub_request(:post, endpoint)
      .with(body: { query: "query B { b }", variables: {} }.to_json)
      .to_return(status: 200, body: { data: { "b" => 2 } }.to_json, headers: { "Content-Type" => "application/json" })

    adapter = described_class.new(
      endpoint: endpoint,
      queries: [
        { name: "first", query: "query A { a }" },
        { name: "second", query: "query B { b }" }
      ]
    )

    expect(adapter.fetch).to eq({ "first" => { "a" => 1 }, "second" => { "b" => 2 } })
  end
end
