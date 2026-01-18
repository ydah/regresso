# frozen_string_literal: true

require "securerandom"
require "time"

module Regresso
  module History
    # Manages persistence and queries for historical results.
    class Store
      # @param storage_backend [Regresso::History::FileBackend]
      def initialize(storage_backend: FileBackend.new)
        @backend = storage_backend
      end

      # @param result [Regresso::Parallel::ParallelResult]
      # @param metadata [Hash]
      # @return [Regresso::History::Entry]
      def record(result, metadata = {})
        entry = Entry.new(
          id: SecureRandom.uuid,
          timestamp: Time.now,
          result: serialize_result(result),
          metadata: metadata
        )
        @backend.save(entry)
        entry
      end

      # @param id [String]
      # @return [Regresso::History::Entry,nil]
      def find(id)
        @backend.find(id)
      end

      # @param filters [Hash]
      # @return [Array<Regresso::History::Entry>]
      def list(filters = {})
        entries = @backend.all
        filter_entries(entries, filters)
      end

      # @param start_date [Time,nil]
      # @param end_date [Time,nil]
      # @param status [Symbol,nil]
      # @param limit [Integer,nil]
      # @return [Array<Regresso::History::Entry>]
      def query(start_date: nil, end_date: nil, status: nil, limit: nil)
        entries = @backend.all
        entries = entries.select do |entry|
          within_range?(entry, start_date, end_date) && status_match?(entry, status)
        end
        limit ? entries.first(limit) : entries
      end

      # @param period [Symbol]
      # @return [Hash]
      def statistics(period: :week)
        entries = list_for_period(period)
        Statistics.new(entries).calculate
      end

      private

      def serialize_result(result)
        {
          total: result.total,
          passed: result.passed,
          failed: result.failed,
          errors: result.errors,
          success: result.success?,
          duration: result.total_duration
        }
      end

      def filter_entries(entries, filters)
        return entries if filters.empty?

        entries.select do |entry|
          matches = true
          matches &&= status_match?(entry, filters[:status]) if filters[:status]
          matches &&= within_range?(entry, filters[:start_date], filters[:end_date])
          matches
        end
      end

      def status_match?(entry, status)
        return true unless status

        case status
        when :passed
          entry.passed?
        when :failed
          entry.failed?
        else
          true
        end
      end

      def within_range?(entry, start_date, end_date)
        start_ok = start_date.nil? || entry.timestamp >= start_date
        end_ok = end_date.nil? || entry.timestamp <= end_date
        start_ok && end_ok
      end

      def list_for_period(period)
        now = Time.now
        start_date = case period
                     when :day
                       now - 60 * 60 * 24
                     when :week
                       now - 60 * 60 * 24 * 7
                     when :month
                       now - 60 * 60 * 24 * 30
                     else
                       now - 60 * 60 * 24 * 7
                     end

        query(start_date: start_date)
      end
    end
  end
end
