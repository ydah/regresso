# frozen_string_literal: true

require_relative "lib/regresso/version"

Gem::Specification.new do |spec|
  spec.name = "regresso"
  spec.version = Regresso::VERSION
  spec.authors = ["Yudai Takada"]
  spec.email = ["t.yudai92@gmail.com"]

  spec.summary = "Regression testing framework for Ruby"
  spec.description = "Detect regressions by comparing API responses, CSV exports, and more between environments"
  spec.homepage = "https://github.com/yourname/regresso"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-follow_redirects", "~> 0.3"
  spec.add_dependency "csv", "~> 3.2"
  spec.add_dependency "builder", "~> 3.2"
  spec.add_dependency "base64", "~> 0.2"

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "minitest", "~> 5.18"
  spec.add_development_dependency "webmock", "~> 3.18"
  spec.add_development_dependency "vcr", "~> 6.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "yard", "~> 0.9"
  spec.add_development_dependency "octokit", "~> 6.0"
  spec.add_development_dependency "activerecord", ">= 6.0", "< 7.1"
  spec.add_development_dependency "sqlite3", "~> 1.7"
end
