# frozen_string_literal: true

module Regresso
  module Notifiers
    class Base
      def notify(result)
        return unless should_notify?(result)

        send_notification(build_message(result))
      end

      private

      def should_notify?(_result)
        raise NotImplementedError, "Notifiers must implement #should_notify?"
      end

      def build_message(_result)
        raise NotImplementedError, "Notifiers must implement #build_message"
      end

      def send_notification(_message)
        raise NotImplementedError, "Notifiers must implement #send_notification"
      end
    end
  end
end
