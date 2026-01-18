# frozen_string_literal: true

module Regresso
  class Comparator
    # Creates a comparator for two data sources.
    #
    # @param source_a [#fetch] first data source
    # @param source_b [#fetch] second data source
    # @param config [Regresso::Configuration] comparison config
    def initialize(source_a:, source_b:, config: Configuration.new)
      @source_a = source_a
      @source_b = source_b
      @config = config
    end

    # Compares two sources and returns the comparison result.
    #
    # @return [Regresso::Result]
    def compare
      data_a = fetch_data(@source_a)
      data_b = fetch_data(@source_b)

      differ = Differ.new(@config)
      diffs = differ.diff(data_a, data_b)

      Result.new(
        source_a: @source_a,
        source_b: @source_b,
        diffs: diffs,
        config: @config
      )
    end

    private

    def fetch_data(source)
      unless source.respond_to?(:fetch)
        raise ArgumentError, "source must respond to #fetch"
      end

      source.fetch
    end
  end
end
