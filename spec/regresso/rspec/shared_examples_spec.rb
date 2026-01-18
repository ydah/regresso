# frozen_string_literal: true

require "regresso/rspec/shared_examples"
require "webmock/rspec"

RSpec.describe "Regresso RSpec shared examples" do
  include WebMock::API

  it "runs api_regression examples" do
    config = {
      old_base_url: "https://old.example.com",
      new_base_url: "https://new.example.com",
      patterns: [{ endpoint: "/data" }]
    }

    RSpec.describe "api regression" do
      before do
        stub_request(:get, "https://old.example.com/data")
          .to_return(status: 200, body: { value: 1 }.to_json, headers: { "Content-Type" => "application/json" })
        stub_request(:get, "https://new.example.com/data")
          .to_return(status: 200, body: { value: 1 }.to_json, headers: { "Content-Type" => "application/json" })
      end

      include_examples "regresso:api_regression", config
    end
  end
end
