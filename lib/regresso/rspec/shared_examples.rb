# frozen_string_literal: true

require "regresso/rspec"

::RSpec.shared_examples "regresso:api_regression" do |config|
  config[:patterns].each do |pattern|
    context(pattern[:name] || pattern[:endpoint]) do
      it "has no regression" do
        old_source = Regresso::Adapters::Http.new(
          base_url: config[:old_base_url],
          endpoint: pattern[:endpoint],
          params: pattern[:params] || {},
          headers: pattern[:headers] || {}
        )

        new_source = Regresso::Adapters::Http.new(
          base_url: config[:new_base_url],
          endpoint: pattern[:endpoint],
          params: pattern[:params] || {},
          headers: pattern[:headers] || {}
        )

        expect(new_source)
          .to have_no_regression_from(old_source)
          .with_tolerance(config[:tolerance] || 0.0)
          .ignoring(*(config[:ignore_paths] || []))
      end
    end
  end
end

::RSpec.shared_examples "regresso:csv_regression" do |config|
  it "CSV export has no regression" do
    old_csv = config[:old_csv_source].call
    new_csv = config[:new_csv_source].call

    expect(new_csv)
      .to have_no_regression_from(old_csv)
      .with_tolerance(config[:tolerance] || 0.0)
      .ignoring(*(config[:ignore_columns] || []))
  end
end
