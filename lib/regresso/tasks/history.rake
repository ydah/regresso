# frozen_string_literal: true

require "fileutils"
require "regresso/history"

namespace :regresso do
  namespace :history do
    desc "Print history statistics"
    task :stats, [:period] do |_task, args|
      store = Regresso::History::Store.new
      stats = store.statistics(period: (args[:period] || :week).to_sym)
      puts stats
    end

    desc "Generate history trend report"
    task :report, [:output, :period] do |_task, args|
      store = Regresso::History::Store.new
      reporter = Regresso::History::TrendReporter.new(store)
      output = args[:output] || "tmp/regresso_trends.html"
      FileUtils.mkdir_p(File.dirname(output))
      File.write(output, reporter.generate(period: (args[:period] || :week).to_sym))
      puts "Wrote #{output}"
    end

    desc "Cleanup history entries older than given days"
    task :cleanup, [:days] do |_task, args|
      days = (args[:days] || 30).to_i
      cutoff = Time.now - (60 * 60 * 24 * days)

      backend = Regresso::History::FileBackend.new
      backend.all.each do |entry|
        backend.delete(entry.id) if entry.timestamp < cutoff
      end
    end
  end
end
