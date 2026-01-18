# frozen_string_literal: true

require "regresso/history"
require "tmpdir"

RSpec.describe Regresso::History::TrendReporter do
  it "generates html" do
    Dir.mktmpdir do |dir|
      backend = Regresso::History::FileBackend.new(storage_dir: dir)
      store = Regresso::History::Store.new(storage_backend: backend)
      result = double(total: 1, passed: 1, failed: 0, errors: 0, success?: true, total_duration: 1.0)
      store.record(result)

      html = described_class.new(store).generate
      expect(html).to include("Regresso Trends")
      expect(html).to include("chart")
    end
  end
end
