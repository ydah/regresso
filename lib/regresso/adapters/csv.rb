# frozen_string_literal: true

require "csv"

module Regresso
  module Adapters
    class Csv < Base
      def initialize(path: nil, content: nil, headers: true, col_sep: ",")
        super()
        @path = path
        @content = content
        @headers = headers
        @col_sep = col_sep
      end

      def fetch
        csv_content = @content || File.read(@path)
        rows = CSV.parse(csv_content, headers: @headers, col_sep: @col_sep)
        if @headers
          rows.map(&:to_h)
        else
          rows.map do |row|
            values = row.is_a?(CSV::Row) ? row.fields : row
            values.each_with_index.to_h { |value, index| [index.to_s, value] }
          end
        end
      end

      def description
        @path ? "CSV: #{@path}" : "CSV (inline content)"
      end
    end
  end
end
