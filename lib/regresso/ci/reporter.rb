# frozen_string_literal: true

module Regresso
  module CI
    class Reporter
      def initialize(result)
        @result = result
      end

      def to_junit_xml
        JUnitXmlFormatter.new(@result).format
      end

      def to_github_annotations
        GitHubAnnotationFormatter.new(@result).annotations
      end

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

      def write_junit_xml(path)
        File.write(path, to_junit_xml)
      end
    end
  end
end
