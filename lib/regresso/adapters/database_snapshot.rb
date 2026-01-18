# frozen_string_literal: true

require "active_record"

module Regresso
  module Adapters
    class DatabaseSnapshot < Base
      def initialize(connection_config:, tables:, where_clause: nil)
        super()
        @connection_config = connection_config
        @tables = tables
        @where_clause = where_clause
      end

      def fetch
        with_connection do |conn|
          @tables.each_with_object({}) do |table, acc|
            query = "SELECT * FROM #{table}"
            query += " WHERE #{@where_clause}" if @where_clause
            acc[table.to_s] = conn.exec_query(query).to_a
          end
        end
      end

      def description
        "Database Snapshot: #{@tables.join(", ")}".strip
      end

      private

      def with_connection
        conn = ActiveRecord::Base.establish_connection(@connection_config).connection
        yield conn
      ensure
        conn&.close
      end
    end
  end
end
