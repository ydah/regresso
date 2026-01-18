# frozen_string_literal: true

require "regresso/notifiers"
require "webmock/rspec"

RSpec.describe Regresso::Notifiers::Slack do
  let(:result) { double(success?: false, total: 2, failed: 1, errors: 0) }

  it "posts a message" do
    stub_request(:post, "https://hooks.slack.test").to_return(status: 200, body: "ok")

    notifier = described_class.new(webhook_url: "https://hooks.slack.test", notify_on: :always)
    notifier.notify(result)

    expect(WebMock).to have_requested(:post, "https://hooks.slack.test")
  end

  it "skips notification based on status" do
    stub_request(:post, "https://hooks.slack.test")

    notifier = described_class.new(webhook_url: "https://hooks.slack.test", notify_on: :success)
    notifier.notify(result)

    expect(WebMock).not_to have_requested(:post, "https://hooks.slack.test")
  end
end
