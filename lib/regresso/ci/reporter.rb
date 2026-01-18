# frozen_string_literal: true

module Regresso
  # CI-related reporting helpers.
  module CI
    # Builds CI-friendly reports from parallel results.
    class Reporter
      # @param result [Regresso::Parallel::ParallelResult]
      def initialize(result)
        @result = result
      end

      # @return [String] JUnit XML output
      def to_junit_xml
        JUnitXmlFormatter.new(@result).format
      end

      # @return [Array<Hash>] GitHub annotations payload
      def to_github_annotations
        GitHubAnnotationFormatter.new(@result).annotations
      end

      # @return [Hash] GitLab report payload
      def to_gitlab_report
        {
          total: @result.total,
          passed: @result.passed,
          failed: @result.failed,
          errors: @result.errors,
          results: @result.results.map do |res|
            {
              name: res.name,
              status: res.status,
              duration: res.duration
            }
          end
        }
      end

      # Writes JUnit XML output to a file.
      #
      # @param path [String]
      # @return [void]
      def write_junit_xml(path)
        File.write(path, to_junit_xml)
      end
    end
  end
end
