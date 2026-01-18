# frozen_string_literal: true

module Regresso
  module CI
    # Formats parallel results into GitHub Actions annotations.
    class GitHubAnnotationFormatter
      # @param result [Regresso::Parallel::ParallelResult]
      def initialize(result)
        @result = result
      end

      # @return [Array<Hash>] GitHub annotations payload
      def annotations
        @result.results.map do |res|
          next unless res.failed? || res.error?

          {
            title: "Regresso: #{res.name}",
            file: "regresso",
            line: 1,
            end_line: 1,
            annotation_level: "error",
            message: annotation_message(res)
          }
        end.compact
      end

      # @return [String] GitHub Actions workflow annotation output
      def output_for_workflow
        annotations.map do |annotation|
          "::error file=#{annotation[:file]},line=#{annotation[:line]}::#{annotation[:message]}"
        end.join("\n")
      end

      private

      def annotation_message(res)
        if res.failed?
          "Regression detected"
        else
          "Error: #{res.error.class} - #{res.error.message}"
        end
      end
    end
  end
end
