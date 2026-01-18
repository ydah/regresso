# frozen_string_literal: true

require "csv"

module Regresso
  module Adapters
    # Adapter that parses CSV input into a comparable structure.
    class Csv < Base
      # @param path [String,nil]
      # @param content [String,nil]
      # @param headers [Boolean]
      # @param col_sep [String]
      def initialize(path: nil, content: nil, headers: true, col_sep: ",")
        super()
        @path = path
        @content = content
        @headers = headers
        @col_sep = col_sep
      end

      # Parses CSV into an array of hashes.
      #
      # @return [Array<Hash>]
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

      # @return [String]
      def description
        @path ? "CSV: #{@path}" : "CSV (inline content)"
      end
    end
  end
end
