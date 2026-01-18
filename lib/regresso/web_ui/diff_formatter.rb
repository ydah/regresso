# frozen_string_literal: true

require "cgi"

module Regresso
  module WebUI
    class DiffFormatter
      def format(diffs, mode: :html)
        case mode
        when :html
          diffs.map { |diff| format_html(diff) }.join("\n")
        when :plain
          diffs.map { |diff| format_plain(diff) }.join("\n")
        else
          raise ArgumentError, "Unknown format: #{mode}"
        end
      end

      private

      def format_html(diff)
        type = CGI.escapeHTML(diff["type"].to_s)
        path = CGI.escapeHTML(diff["path"].to_s)
        old_value = CGI.escapeHTML(diff["old_value"].inspect)
        new_value = CGI.escapeHTML(diff["new_value"].inspect)

        <<~HTML.strip
          <div class="diff-row diff-#{type}">
            <span class="diff-path">#{path}</span>
            <span class="diff-old">#{old_value}</span>
            <span class="diff-new">#{new_value}</span>
            <span class="diff-type">#{type}</span>
          </div>
        HTML
      end

      def format_plain(diff)
        "#{diff['path']}: #{diff['old_value'].inspect} -> #{diff['new_value'].inspect}"
      end
    end
  end
end
