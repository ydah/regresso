# frozen_string_literal: true

require "regresso"
require "regresso/snapshot_manager"

module Regresso
  module Minitest
    module Assertions
      # Asserts that two sources have no regression.
      #
      # @param source_a [Object]
      # @param source_b [Object]
      # @param tolerance [Float]
      # @param ignore [Array<String,Regexp>]
      # @param message [String,nil]
      # @return [void]
      def assert_no_regression(source_a, source_b, tolerance: 0.0, ignore: [], message: nil)
        config = Regresso::Configuration.new
        config.default_tolerance = tolerance
        config.ignore_paths = ignore

        comparator = Regresso::Comparator.new(
          source_a: normalize_source(source_a),
          source_b: normalize_source(source_b),
          config: config
        )

        result = comparator.compare

        msg = message || build_failure_message(result)
        assert result.passed?, msg
      end

      # Asserts that an object matches a stored snapshot.
      #
      # @param actual [Object]
      # @param snapshot_name [String]
      # @param tolerance [Float]
      # @param ignore [Array<String,Regexp>]
      # @return [void]
      def assert_matches_snapshot(actual, snapshot_name, tolerance: 0.0, ignore: [])
        manager = Regresso::SnapshotManager.new
        path = manager.path_for(snapshot_name)

        if ENV["UPDATE_SNAPSHOTS"] || !File.exist?(path)
          manager.save(snapshot_name, actual)
          pass
        else
          expected = manager.load(snapshot_name)
          assert_no_regression(expected, actual, tolerance: tolerance, ignore: ignore)
        end
      end

      private

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

      def build_failure_message(result)
        diffs = result.meaningful_diffs
        "Expected no regression, found #{diffs.size} difference(s):\n" +
          diffs.first(5).map { |diff| "  #{diff}" }.join("\n")
      end
    end
  end
end

if defined?(::Minitest::Test)
  ::Minitest::Test.include Regresso::Minitest::Assertions
end
