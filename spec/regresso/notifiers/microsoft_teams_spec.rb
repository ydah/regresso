# frozen_string_literal: true

require "regresso/notifiers"
require "webmock/rspec"

RSpec.describe Regresso::Notifiers::MicrosoftTeams do
  let(:result) { double(success?: true, total: 1, passed: 1, failed: 0, errors: 0) }

  it "posts a message card" do
    stub_request(:post, "https://hooks.teams.test").to_return(status: 200, body: "ok")

    notifier = described_class.new(webhook_url: "https://hooks.teams.test", notify_on: :always)
    notifier.notify(result)

    expect(WebMock).to have_requested(:post, "https://hooks.teams.test")
  end
end
