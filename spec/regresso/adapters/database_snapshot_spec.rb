# frozen_string_literal: true

require "regresso"
require "tmpdir"

RSpec.describe Regresso::Adapters::DatabaseSnapshot do
  let(:config) do
    {
      adapter: "sqlite3",
      database: db_path
    }
  end

  let(:db_path) do
    file = Tempfile.new(["regresso", ".sqlite3"])
    file.close
    file.path
  end

  before do
    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::Base.connection.create_table(:users, force: true) do |t|
      t.string :name
    end
    ActiveRecord::Base.connection.create_table(:orders, force: true) do |t|
      t.integer :amount
    end
    ActiveRecord::Base.connection.execute("INSERT INTO users (name) VALUES ('alice')")
    ActiveRecord::Base.connection.execute("INSERT INTO orders (amount) VALUES (100)")
    ActiveRecord::Base.connection.close
  end

  after do
    File.delete(db_path) if File.exist?(db_path)
  end

  it "returns snapshots for tables" do
    adapter = described_class.new(connection_config: config, tables: %i[users orders])
    snapshot = adapter.fetch

    expect(snapshot.keys).to contain_exactly("users", "orders")
    expect(snapshot["users"].first["name"]).to eq("alice")
  end
end
