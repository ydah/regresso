# frozen_string_literal: true

require "regresso"
require "tmpdir"

RSpec.describe Regresso::Adapters::Database do
  let(:config) do
    {
      adapter: "sqlite3",
      database: db_path
    }
  end

  let(:db_file) { Tempfile.new(["regresso", ".sqlite3"]) }
  let(:db_path) { db_file.path }

  before do
    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::Base.connection.create_table(:items, force: true) do |t|
      t.string :name
      t.integer :price
    end
    ActiveRecord::Base.connection.execute("INSERT INTO items (name, price) VALUES ('a', 10), ('b', 5)")
    ActiveRecord::Base.connection.close
  end

  after do
    db_file.close
    db_file.unlink
  end

  it "runs a query" do
    adapter = described_class.new(connection_config: config, query: "SELECT * FROM items")
    rows = adapter.fetch

    expect(rows.size).to eq(2)
    expect(rows.first).to include("name")
  end

  it "sorts by row identifier" do
    adapter = described_class.new(
      connection_config: config,
      query: "SELECT * FROM items",
      row_identifier: :price
    )

    rows = adapter.fetch
    expect(rows.first["price"]).to eq(5)
  end
end
