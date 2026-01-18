# frozen_string_literal: true

require "active_record"

module Regresso
  module Adapters
    # Adapter that collects full table snapshots from a database.
    class DatabaseSnapshot < Base
      # @param connection_config [Hash]
      # @param tables [Array<String,Symbol>]
      # @param where_clause [String,nil]
      def initialize(connection_config:, tables:, where_clause: nil)
        super()
        @connection_config = connection_config
        @tables = tables
        @where_clause = where_clause
      end

      # Fetches rows for each table into a hash keyed by table name.
      #
      # @return [Hash{String => Array<Hash>}]
      def fetch
        with_connection do |conn|
          @tables.each_with_object({}) do |table, acc|
            query = "SELECT * FROM #{table}"
            query += " WHERE #{@where_clause}" if @where_clause
            acc[table.to_s] = conn.exec_query(query).to_a
          end
        end
      end

      # @return [String]
      def description
        "Database Snapshot: #{@tables.join(", ")}".strip
      end

      private

      def with_connection
        ActiveRecord::Base.establish_connection(@connection_config)
        ActiveRecord::Base.connection_pool.with_connection do |conn|
          yield conn
        end
      ensure
        ActiveRecord::Base.connection_pool.disconnect! if ActiveRecord::Base.connected?
      end
    end
  end
end
