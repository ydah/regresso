# frozen_string_literal: true

require "json"
require "faraday"

module Regresso
  module Notifiers
    class MicrosoftTeams < Base
      def initialize(webhook_url:, notify_on: :failure)
        @webhook_url = webhook_url
        @notify_on = notify_on
      end

      private

      def should_notify?(result)
        case @notify_on
        when :always
          true
        when :failure
          !result.success?
        when :success
          result.success?
        else
          false
        end
      end

      def build_message(result)
        {
          "@type" => "MessageCard",
          "@context" => "http://schema.org/extensions",
          "summary" => "Regresso Report",
          "themeColor" => result.success? ? "2ECC71" : "E74C3C",
          "title" => "Regresso Report",
          "sections" => [
            {
              "facts" => [
                { "name" => "Total", "value" => result.total.to_s },
                { "name" => "Passed", "value" => result.passed.to_s },
                { "name" => "Failed", "value" => result.failed.to_s },
                { "name" => "Errors", "value" => result.errors.to_s }
              ]
            }
          ]
        }
      end

      def send_notification(message)
        Faraday.post(@webhook_url) do |req|
          req.headers["Content-Type"] = "application/json"
          req.body = JSON.generate(message)
        end
      end
    end
  end
end
