# frozen_string_literal: true

require "builder"

module Regresso
  module CI
    class JUnitXmlFormatter
      def initialize(result)
        @result = result
      end

      def format
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.instruct!

        builder.testsuites(
          name: "Regresso Regression Tests",
          tests: @result.total,
          failures: @result.failed,
          errors: @result.errors
        ) do |suites|
          suites.testsuite(name: "Regression", tests: @result.total) do |suite|
            @result.results.each do |res|
              suite.testcase(name: res.name, time: res.duration) do |tc|
                if res.failed?
                  tc.failure(message: "Regression detected", type: "RegressionFailure")
                elsif res.error?
                  tc.error(message: res.error.message, type: res.error.class.name)
                end
              end
            end
          end
        end

        builder.target!
      end
    end
  end
end
