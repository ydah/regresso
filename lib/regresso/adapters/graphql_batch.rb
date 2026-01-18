# frozen_string_literal: true

require "regresso/adapters/graphql"

module Regresso
  module Adapters
    class GraphQLBatch < Base
      def initialize(endpoint:, queries:, headers: {})
        super()
        @endpoint = endpoint
        @queries = queries
        @headers = headers
      end

      def fetch
        @queries.each_with_object({}) do |query, acc|
          adapter = GraphQL.new(
            endpoint: @endpoint,
            query: query.fetch(:query),
            variables: query[:variables] || {},
            headers: @headers,
            operation_name: query[:operation_name]
          )

          acc[query.fetch(:name).to_s] = adapter.fetch
        end
      end

      def description
        "GraphQL Batch: #{@queries.size} queries"
      end
    end
  end
end
