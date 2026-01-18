# frozen_string_literal: true

require "fileutils"
require "regresso/parallel"
require "regresso/ci"

namespace :regresso do
  desc "Run regression comparisons and write JUnit XML"
  task :run, [:comparisons_file, :output] do |_task, args|
    file = args[:comparisons_file] || ENV["REGRESSO_COMPARISONS"]
    raise "comparisons file is required" unless file
    raise "comparisons file not found: #{file}" unless File.exist?(file)

    load file
    comparisons = Object.const_get("REGRESSO_COMPARISONS")

    runner = Regresso::Parallel::Runner.new(comparisons: comparisons)
    result = runner.run
    reporter = Regresso::CI::Reporter.new(result)

    output = args[:output] || ENV["REGRESSO_JUNIT_XML"] || "tmp/regresso-junit.xml"
    FileUtils.mkdir_p(File.dirname(output))
    reporter.write_junit_xml(output)

    puts "Regresso result: #{result.summary}"
  end

  desc "Post Regresso report as a GitHub PR comment"
  task :comment_pr, [:comparisons_file] do |_task, args|
    token = ENV["GITHUB_TOKEN"]
    repo = ENV["GITHUB_REPOSITORY"]
    pr_number = ENV["GITHUB_PR_NUMBER"]&.to_i

    raise "GITHUB_TOKEN is required" unless token
    raise "GITHUB_REPOSITORY is required" unless repo
    raise "GITHUB_PR_NUMBER is required" unless pr_number

    file = args[:comparisons_file] || ENV["REGRESSO_COMPARISONS"]
    raise "comparisons file is required" unless file
    raise "comparisons file not found: #{file}" unless File.exist?(file)

    load file
    comparisons = Object.const_get("REGRESSO_COMPARISONS")

    runner = Regresso::Parallel::Runner.new(comparisons: comparisons)
    result = runner.run

    commenter = Regresso::CI::GitHubPRCommenter.new(token: token, repo: repo, pr_number: pr_number)
    commenter.post_comment(result)
  end
end
