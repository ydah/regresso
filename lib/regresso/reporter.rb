# frozen_string_literal: true

require "json"
require "erb"

module Regresso
  class Reporter
    # @param result [Regresso::Result]
    def initialize(result)
      @result = result
    end

    # Generates a report string.
    #
    # @param format [Symbol]
    # @return [String]
    def generate(format)
      case format
      when :text
        to_text
      when :json
        to_json
      when :html
        to_html
      else
        raise ArgumentError, "Unknown format: #{format}"
      end
    end

    private

    def to_text
      lines = []
      lines << "Regresso Report"
      lines << "Passed: #{@result.passed?}"
      lines << "Total diffs: #{@result.diffs.size}"
      lines << "Meaningful diffs: #{@result.meaningful_diffs.size}"
      lines << ""

      @result.meaningful_diffs.each do |diff|
        lines << "- #{diff}"
      end

      lines.join("\n")
    end

    def to_json
      {
        summary: @result.summary,
        diffs: @result.diffs.map do |diff|
          {
            path: diff.path.to_s,
            old_value: diff.old_value,
            new_value: diff.new_value,
            type: diff.type
          }
        end
      }.to_json
    end

    def to_html
      template_path = File.expand_path("templates/report.html.erb", __dir__)
      template = File.read(template_path)
      ERB.new(template).result(binding)
    end
  end
end
