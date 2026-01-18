# frozen_string_literal: true

require "faraday"
require "json"

module Regresso
  module Adapters
    # Adapter that executes GraphQL queries over HTTP.
    class GraphQL < Base
      # @param endpoint [String]
      # @param query [String]
      # @param variables [Hash]
      # @param headers [Hash]
      # @param operation_name [String,nil]
      def initialize(endpoint:, query:, variables: {}, headers: {}, operation_name: nil)
        super()
        @endpoint = endpoint
        @query = query
        @variables = variables
        @headers = headers
        @operation_name = operation_name
      end

      # Executes the GraphQL query and returns the data payload.
      #
      # @return [Object]
      def fetch
        response = connection.post do |req|
          req.headers = default_headers.merge(@headers)
          req.body = {
            query: @query,
            variables: @variables,
            operationName: @operation_name
          }.compact.to_json
        end

        data = response.body
        raise GraphQLError, data["errors"] if data["errors"]&.any?

        data["data"]
      end

      # @return [String]
      def description
        "GraphQL: #{@operation_name || "anonymous"}"
      end

      private

      def connection
        @connection ||= Faraday.new(url: @endpoint) do |faraday|
          faraday.request :json
          faraday.response :json
          faraday.adapter Faraday.default_adapter
        end
      end

      def default_headers
        { "Content-Type" => "application/json", "Accept" => "application/json" }
      end
    end

    # Raised when a GraphQL response contains errors.
    class GraphQLError < StandardError
      # @return [Array<Hash>]
      attr_reader :errors

      # @param errors [Array<Hash>]
      def initialize(errors)
        @errors = errors
        super(errors.map { |error| error["message"] }.join(", "))
      end
    end
  end
end
