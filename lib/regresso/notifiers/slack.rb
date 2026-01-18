# frozen_string_literal: true

require "json"
require "faraday"

module Regresso
  module Notifiers
    # Slack webhook notifier.
    class Slack < Base
      # @param webhook_url [String]
      # @param channel [String,nil]
      # @param notify_on [Symbol] :always, :failure, or :success
      # @param mention [String,nil]
      # @param username [String,nil]
      # @param icon_emoji [String,nil]
      def initialize(webhook_url:, channel: nil, notify_on: :failure, mention: nil, username: nil, icon_emoji: nil)
        @webhook_url = webhook_url
        @channel = channel
        @notify_on = notify_on
        @mention = mention
        @username = username
        @icon_emoji = icon_emoji
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
        status_text = result.success? ? "Tests passed" : "Regression detected"
        text = [@mention, status_text].compact.join(" ")

        message = {
          channel: @channel,
          username: @username,
          icon_emoji: @icon_emoji,
          text: text,
          attachments: [
            {
              color: result.success? ? "good" : "danger",
              fields: [
                { title: "Total", value: result.total.to_s, short: true },
                { title: "Failed", value: result.failed.to_s, short: true },
                { title: "Errors", value: result.errors.to_s, short: true }
              ]
            }
          ]
        }

        message.delete_if { |_key, value| value.nil? }
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
