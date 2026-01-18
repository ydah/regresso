# frozen_string_literal: true

require "regresso/notifiers"

RSpec.describe Regresso::Notifiers::Base do
  it "raises for abstract methods" do
    notifier = described_class.new
    expect { notifier.send(:should_notify?, double) }.to raise_error(NotImplementedError)
    expect { notifier.send(:build_message, double) }.to raise_error(NotImplementedError)
    expect { notifier.send(:send_notification, {}) }.to raise_error(NotImplementedError)
  end
end
