# frozen_string_literal: true

require "regresso"
require "regresso/snapshot_manager"

module Regresso
  # RSpec integration for Regresso.
  module RSpec
    # Custom matchers for regression and snapshot comparisons.
    module Matchers
      extend ::RSpec::Matchers::DSL

      matcher :have_no_regression_from do |source_a|
        match do |source_b|
          @config = build_config
          @comparator = Regresso::Comparator.new(
            source_a: normalize_source(source_a),
            source_b: normalize_source(source_b),
            config: @config
          )
          @result = @comparator.compare
          @result.passed?
        end

        chain :with_tolerance do |tolerance|
          @tolerance = tolerance
        end

        chain :ignoring do |*paths|
          @ignore_paths = paths.flatten
        end

        chain :with_path_tolerance do |path, tolerance|
          @path_tolerances ||= {}
          @path_tolerances[path] = tolerance
        end

        chain :order_insensitive do
          @order_insensitive = true
        end

        failure_message do
          message = "Expected no regression, but found #{@result.meaningful_diffs.size} difference(s):\n\n"
          @result.meaningful_diffs.first(10).each do |diff|
            message += "  - #{diff}\n"
          end
          if @result.meaningful_diffs.size > 10
            message += "  ... and #{@result.meaningful_diffs.size - 10} more\n"
          end
          message
        end

        failure_message_when_negated do
          "Expected regression, but none found"
        end

        private

        def build_config
          Regresso::Configuration.new.tap do |config|
            config.default_tolerance = @tolerance if @tolerance
            config.ignore_paths = @ignore_paths if @ignore_paths
            config.tolerance_overrides = @path_tolerances if @path_tolerances
            config.array_order_sensitive = !@order_insensitive
          end
        end

        def normalize_source(source)
          case source
          when Regresso::Adapters::Base
            source
          when Hash
            if source[:url] || source[:base_url]
              base_url = source[:base_url] || source[:url]
              Regresso::Adapters::Http.new(**source.merge(base_url: base_url).reject { |k, _| k == :url })
            elsif source[:path] && source[:path].to_s.end_with?(".csv")
              Regresso::Adapters::Csv.new(**source)
            elsif source[:path]
              Regresso::Adapters::JsonFile.new(**source)
            else
              Regresso::Adapters::Proc.new { source }
            end
          when String
            if source.end_with?(".csv")
              Regresso::Adapters::Csv.new(path: source)
            else
              Regresso::Adapters::JsonFile.new(path: source)
            end
          when ::Proc
            Regresso::Adapters::Proc.new(source)
          else
            Regresso::Adapters::Proc.new { source }
          end
        end
      end

      matcher :match_snapshot do |snapshot_name|
        match do |actual|
          @snapshot_manager = Regresso::SnapshotManager.new
          @snapshot_path = @snapshot_manager.path_for(snapshot_name)

          if ENV["UPDATE_SNAPSHOTS"] || !File.exist?(@snapshot_path)
            @snapshot_manager.save(snapshot_name, actual)
            true
          else
            @config = build_snapshot_config
            expected = @snapshot_manager.load(snapshot_name)
            differ = Regresso::Differ.new(@config)
            @diffs = differ.diff(expected, actual)
            @diffs.empty?
          end
        end

        chain :with_tolerance do |tolerance|
          @tolerance = tolerance
        end

        chain :ignoring do |*paths|
          @ignore_paths = paths.flatten
        end

        failure_message do
          "Snapshot mismatch for '#{snapshot_name}':\n" +
            @diffs.first(10).map { |diff| "  - #{diff}" }.join("\n")
        end

        private

        def build_snapshot_config
          Regresso::Configuration.new.tap do |config|
            config.default_tolerance = @tolerance || 0.0
            config.ignore_paths = @ignore_paths || []
          end
        end
      end
    end
  end
end

::RSpec.configure do |config|
  config.include Regresso::RSpec::Matchers
end
