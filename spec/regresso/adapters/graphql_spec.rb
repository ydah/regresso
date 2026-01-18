# frozen_string_literal: true

require "regresso"
require "webmock/rspec"

RSpec.describe Regresso::Adapters::GraphQL do
  let(:endpoint) { "https://example.com/graphql" }
  let(:query) { "query Test { value }" }

  it "executes a graphql query" do
    stub_request(:post, endpoint)
      .with(body: { query: query, variables: {} }.to_json)
      .to_return(status: 200, body: { data: { "value" => 1 } }.to_json, headers: { "Content-Type" => "application/json" })

    adapter = described_class.new(endpoint: endpoint, query: query)
    expect(adapter.fetch).to eq({ "value" => 1 })
  end

  it "raises on graphql errors" do
    stub_request(:post, endpoint)
      .to_return(status: 200, body: { errors: [{ "message" => "boom" }] }.to_json, headers: { "Content-Type" => "application/json" })

    adapter = described_class.new(endpoint: endpoint, query: query)
    expect { adapter.fetch }.to raise_error(Regresso::Adapters::GraphQLError)
  end

  it "sends variables" do
    variables = { "id" => 1 }
    stub_request(:post, endpoint)
      .with(body: { query: query, variables: variables }.to_json)
      .to_return(status: 200, body: { data: { "value" => 1 } }.to_json, headers: { "Content-Type" => "application/json" })

    adapter = described_class.new(endpoint: endpoint, query: query, variables: variables)
    expect(adapter.fetch).to eq({ "value" => 1 })
  end
end
