# frozen_string_literal: true

require "active_record"

module Regresso
  module Adapters
    class Database < Base
      def initialize(connection_config:, query:, params: {}, row_identifier: nil)
        super()
        @connection_config = connection_config
        @query = query
        @params = params
        @row_identifier = row_identifier
      end

      def fetch
        with_connection do |conn|
          result = conn.exec_query(sanitize_query)
          rows = result.to_a
          @row_identifier ? rows.sort_by { |row| row[@row_identifier.to_s] } : rows
        end
      end

      def description
        "Database Query: #{@query.to_s.tr("\n", " ")[0, 50]}"
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

      def sanitize_query
        ActiveRecord::Base.sanitize_sql_array([@query, @params])
      end
    end
  end
end
