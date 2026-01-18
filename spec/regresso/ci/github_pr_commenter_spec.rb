# frozen_string_literal: true

require "regresso/ci"
require "webmock/rspec"

RSpec.describe Regresso::CI::GitHubPRCommenter do
  let(:client) { instance_double(Octokit::Client) }
  let(:comment) { instance_double("Octokit::Comment", id: 123, body: "<!-- regresso-report -->") }

  before do
    allow(Octokit::Client).to receive(:new).and_return(client)
  end

  it "creates a comment when none exists" do
    allow(client).to receive(:issue_comments).and_return([])
    expect(client).to receive(:add_comment)

    commenter = described_class.new(token: "token", repo: "owner/repo", pr_number: 1)
    commenter.post_comment(double(passed: 1, failed: 0, errors: 0, total: 1))
  end

  it "updates an existing comment" do
    allow(client).to receive(:issue_comments).and_return([comment])
    expect(client).to receive(:update_comment)

    commenter = described_class.new(token: "token", repo: "owner/repo", pr_number: 1)
    commenter.post_comment(double(passed: 1, failed: 1, errors: 0, total: 2))
  end
end
