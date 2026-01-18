# frozen_string_literal: true

require "octokit"

module Regresso
  module CI
    class GitHubPRCommenter
      def initialize(token:, repo:, pr_number:)
        @client = Octokit::Client.new(access_token: token)
        @repo = repo
        @pr_number = pr_number
      end

      def post_comment(result)
        body = build_comment_body(result)
        existing = find_existing_comment
        if existing
          @client.update_comment(@repo, existing.id, body)
        else
          @client.add_comment(@repo, @pr_number, body)
        end
      end

      private

      def find_existing_comment
        @client.issue_comments(@repo, @pr_number).find do |comment|
          comment.body.include?("<!-- regresso-report -->")
        end
      end

      def build_comment_body(result)
        <<~MARKDOWN
          <!-- regresso-report -->
          ## Regresso Report

          | Status | Count |
          |--------|-------|
          | Passed | #{result.passed} |
          | Failed | #{result.failed} |
          | Errors | #{result.errors} |
          | Total | #{result.total} |
        MARKDOWN
      end
    end
  end
end
