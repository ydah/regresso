# frozen_string_literal: true

require "faraday"
require "json"

module Regresso
  module Adapters
    class GraphQL < Base
      def initialize(endpoint:, query:, variables: {}, headers: {}, operation_name: nil)
        super()
        @endpoint = endpoint
        @query = query
        @variables = variables
        @headers = headers
        @operation_name = operation_name
      end

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

    class GraphQLError < StandardError
      attr_reader :errors

      def initialize(errors)
        @errors = errors
        super(errors.map { |error| error["message"] }.join(", "))
      end
    end
  end
end
