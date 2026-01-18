# frozen_string_literal: true

require "regresso"

RSpec.describe Regresso::Adapters::Base do
  it "raises for unimplemented fetch" do
    adapter = described_class.new
    expect { adapter.fetch }.to raise_error(NotImplementedError)
  end

  it "raises for unimplemented description" do
    adapter = described_class.new
    expect { adapter.description }.to raise_error(NotImplementedError)
  end
end
