# frozen_string_literal: true

require "octokit"

module Regresso
  module CI
    # Posts a summary comment to a GitHub pull request.
    class GitHubPRCommenter
      # @param token [String]
      # @param repo [String]
      # @param pr_number [Integer]
      def initialize(token:, repo:, pr_number:)
        @client = Octokit::Client.new(access_token: token)
        @repo = repo
        @pr_number = pr_number
      end

      # Creates or updates a PR comment with the report summary.
      #
      # @param result [Regresso::Parallel::ParallelResult]
      # @return [void]
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
