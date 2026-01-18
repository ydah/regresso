# frozen_string_literal: true

RSpec.describe Regresso do
  it "has a version number" do
    expect(Regresso::VERSION).not_to be nil
  end

  it "configures and returns configuration" do
    Regresso.configure do |config|
      config.default_tolerance = 0.25
    end

    expect(Regresso.configuration).to be_a(Regresso::Configuration)
    expect(Regresso.configuration.default_tolerance).to eq(0.25)
  end

  it "resets configuration" do
    Regresso.configure do |config|
      config.default_tolerance = 0.5
    end

    Regresso.reset_configuration!
    expect(Regresso.configuration.default_tolerance).to eq(0.0)
  end
end
