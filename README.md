<p align="center">
  <img src="assets/logo-header.svg" alt="regresso header logo">
  <b>Regression testing for Ruby APIs, files, and data snapshots.</b>
  <br>
  Compare outputs across environments with tolerances and ignore rules.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/ruby-%3E%3D%203.2-ruby.svg" alt="Ruby Version">
  <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License">
  <a href="https://badge.fury.io/rb/regresso"><img src="https://badge.fury.io/rb/regresso.svg" alt="Gem Version" height="18"></a>
  <a href="https://github.com/ydah/regresso/actions/workflows/main.yml">
    <img src="https://github.com/ydah/regresso/actions/workflows/main.yml/badge.svg" alt="CI Status">
  </a>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#how-it-works">How It Works</a> •
  <a href="#installation">Installation</a> •
  <a href="#configuration">Configuration</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#web-ui">Web UI</a>
</p>

## Features

- Compare API responses, CSV exports, JSON files, or custom data sources
- Tolerances and per-path overrides for numeric differences
- Ignore paths by JSONPath or regex to avoid noisy fields
- Snapshot testing for stable outputs
- RSpec and Minitest integrations
- GraphQL, database, and batch comparisons
- Parallel execution with CI-ready reports
- Optional Web UI for browsing results

## Quick Start

```ruby
require "regresso/rspec"

old_api = { base_url: "https://old.example.com", endpoint: "/reports/sales" }
new_api = { base_url: "https://new.example.com", endpoint: "/reports/sales" }

RSpec.describe "Sales report" do
  it "has no regression" do
    expect(new_api).to have_no_regression_from(old_api)
      .with_tolerance(0.01)
      .ignoring("$.timestamp")
  end
end
```

## How It Works

1. Build two data sources (old and new)
2. Normalize and compare outputs
3. Apply tolerances and ignore rules
4. Report a diff summary and pass/fail result

## Usage Examples

### API comparison

```ruby
old_source = Regresso::Adapters::Http.new(
  base_url: "https://old.example.com",
  endpoint: "/api/v1/reports",
  params: { year: 2024 }
)

new_source = Regresso::Adapters::Http.new(
  base_url: "https://new.example.com",
  endpoint: "/api/v1/reports",
  params: { year: 2024 }
)

result = Regresso::Comparator.new(source_a: old_source, source_b: new_source).compare
puts result.summary
```

### CSV comparison

```ruby
old_csv = Regresso::Adapters::Csv.new(path: "tmp/old.csv")
new_csv = Regresso::Adapters::Csv.new(path: "tmp/new.csv")

result = Regresso::Comparator.new(source_a: old_csv, source_b: new_csv).compare
puts result.passed?
```

### Snapshot testing

```ruby
require "regresso/rspec"

RSpec.describe "Snapshot" do
  it "matches snapshot" do
    payload = { "total" => 120 }
    expect(payload).to match_snapshot("report_total")
  end
end
```

### Tolerance and ignore paths

```ruby
expect(new_api).to have_no_regression_from(old_api)
  .with_tolerance(0.01)
  .with_path_tolerance("$.amount", 0.1)
  .ignoring("$.updated_at")
```

### Shared examples

```ruby
require "regresso/rspec/shared_examples"

include_examples "regresso:api_regression", {
  old_base_url: ENV["OLD_API"],
  new_base_url: ENV["NEW_API"],
  patterns: [{ endpoint: "/api/v1/reports" }]
}
```

### Database query comparison

```ruby
old_db = Regresso::Adapters::Database.new(
  connection_config: { adapter: "sqlite3", database: "tmp/old.db" },
  query: "SELECT * FROM users WHERE active = :active",
  params: { active: true },
  row_identifier: :id
)

new_db = Regresso::Adapters::Database.new(
  connection_config: { adapter: "sqlite3", database: "tmp/new.db" },
  query: "SELECT * FROM users WHERE active = :active",
  params: { active: true },
  row_identifier: :id
)

result = Regresso::Comparator.new(source_a: old_db, source_b: new_db).compare
puts result.summary
```

### GraphQL batch comparison

```ruby
source_a = Regresso::Adapters::GraphQLBatch.new(
  endpoint: "https://old.example.com/graphql",
  queries: [
    { name: "users", query: "{ users { id name } }" },
    { name: "stats", query: "{ stats { total } }" }
  ]
)

source_b = Regresso::Adapters::GraphQLBatch.new(
  endpoint: "https://new.example.com/graphql",
  queries: [
    { name: "users", query: "{ users { id name } }" },
    { name: "stats", query: "{ stats { total } }" }
  ]
)

result = Regresso::Comparator.new(source_a: source_a, source_b: source_b).compare
puts result.passed?
```

### Parallel comparisons

```ruby
comparisons = [
  {
    name: "sales",
    source_a: Regresso::Adapters::Proc.new { { total: 120 } },
    source_b: Regresso::Adapters::Proc.new { { total: 121 } }
  }
]

runner = Regresso::Parallel::Runner.new(comparisons: comparisons, workers: 4)
parallel_result = runner.run
puts parallel_result.summary
```

## Installation

Add to your Gemfile:

```bash
bundle add regresso
```

Or install directly:

```bash
gem install regresso
```

## Configuration

```ruby
Regresso.configure do |config|
  config.default_tolerance = 0.01
  config.ignore_paths = [/\.id$/, /\.updated_at$/]
  config.tolerance_overrides = { "$.amount" => 0.1 }
  config.array_order_sensitive = true
  config.type_coercion = true
end
```

## Adapters

- HTTP: `Regresso::Adapters::Http`
- CSV: `Regresso::Adapters::Csv`
- JSON file: `Regresso::Adapters::JsonFile`
- Proc: `Regresso::Adapters::Proc`
- Database query: `Regresso::Adapters::Database`
- Database snapshot: `Regresso::Adapters::DatabaseSnapshot`
- GraphQL: `Regresso::Adapters::GraphQL`
- GraphQL batch: `Regresso::Adapters::GraphQLBatch`

## Test framework integration

- RSpec: `require "regresso/rspec"`
- Minitest: `require "regresso/minitest"`

## Documentation

```bash
bundle exec rake yard
```

## CI reporting

```ruby
reporter = Regresso::CI::Reporter.new(parallel_result)
File.write("tmp/regresso.xml", reporter.to_junit_xml)
```

## Web UI

```ruby
require "regresso/web_ui"

store = Regresso::WebUI::ResultStore.new(storage_path: "tmp/regresso_results")
Regresso::WebUI::Server.set :result_store, store
Regresso::WebUI::Server.run!
```

## Contributing

Bug reports and pull requests are welcome. Please run tests before submitting changes.

## License

MIT License. See `LICENSE.txt` for details.
