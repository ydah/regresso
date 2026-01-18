# frozen_string_literal: true

require "rack/test"
require "regresso/web_ui"
require "tmpdir"

RSpec.describe Regresso::WebUI::Server do
  include Rack::Test::Methods

  def app
    storage = Dir.mktmpdir
    described_class.set :result_store, Regresso::WebUI::ResultStore.new(storage_path: storage)
    described_class
  end

  it "serves index" do
    get "/"
    expect(last_response.status).to eq(200)
  end

  it "creates and retrieves results" do
    post "/api/results", { name: "Run", summary: { passed: true }, diffs: [] }.to_json
    expect(last_response.status).to eq(201)

    id = JSON.parse(last_response.body)["id"]
    get "/api/results/#{id}"
    expect(last_response.status).to eq(200)
  end

  it "filters diffs" do
    post "/api/results", {
      name: "Run",
      summary: { passed: false },
      diffs: [
        { path: "$.a", old_value: 1, new_value: 2, type: "changed" },
        { path: "$.b", old_value: nil, new_value: 1, type: "added" }
      ]
    }.to_json

    id = JSON.parse(last_response.body)["id"]
    get "/api/results/#{id}/diffs?type=added"

    data = JSON.parse(last_response.body)
    expect(data["diffs"].size).to eq(1)
    expect(data["diffs"].first["type"]).to eq("added")
  end
end
