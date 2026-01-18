# frozen_string_literal: true

require "regresso/history"
require "tmpdir"

RSpec.describe Regresso::History::Store do
  it "records and finds entries" do
    Dir.mktmpdir do |dir|
      backend = Regresso::History::FileBackend.new(storage_dir: dir)
      store = described_class.new(storage_backend: backend)

      result = double(total: 1, passed: 1, failed: 0, errors: 0, success?: true, total_duration: 1.0)
      entry = store.record(result, { "error" => nil })

      expect(store.find(entry.id)).not_to be_nil
    end
  end

  it "queries by status" do
    Dir.mktmpdir do |dir|
      backend = Regresso::History::FileBackend.new(storage_dir: dir)
      store = described_class.new(storage_backend: backend)

      passed = double(total: 1, passed: 1, failed: 0, errors: 0, success?: true, total_duration: 1.0)
      failed = double(total: 1, passed: 0, failed: 1, errors: 0, success?: false, total_duration: 1.0)
      store.record(passed)
      store.record(failed)

      expect(store.query(status: :passed).size).to eq(1)
      expect(store.query(status: :failed).size).to eq(1)
    end
  end
end
