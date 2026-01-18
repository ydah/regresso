# frozen_string_literal: true

require "faraday"
require "faraday/follow_redirects"

module Regresso
  module Adapters
    # Adapter that fetches data from an HTTP endpoint.
    class Http < Base
      # @param base_url [String]
      # @param endpoint [String]
      # @param params [Hash]
      # @param headers [Hash]
      # @param method [Symbol]
      def initialize(base_url:, endpoint:, params: {}, headers: {}, method: :get)
        super()
        @base_url = base_url
        @endpoint = endpoint
        @params = params
        @headers = headers
        @method = method
      end

      # Executes the HTTP request and returns parsed response.
      #
      # @return [Object]
      def fetch
        response = connection.public_send(@method, @endpoint) do |req|
          req.params = @params
          req.headers = @headers
        end

        if response.status >= 400
          raise Regresso::Error, "HTTP request failed with status #{response.status}"
        end

        parse_response(response)
      end

      # @return [String]
      def description
        "#{@method.to_s.upcase} #{@base_url}#{@endpoint}"
      end

      private

      def connection
        @connection ||= Faraday.new(url: @base_url) do |faraday|
          faraday.request :json
          faraday.response :json
          faraday.response :follow_redirects
          faraday.adapter Faraday.default_adapter
        end
      end

      def parse_response(response)
        content_type = response.headers["content-type"].to_s
        return response.body if content_type.empty?

        if content_type.match?(/json/)
          response.body
        elsif content_type.match?(/csv/)
          response.body
        else
          response.body
        end
      end
    end
  end
end
