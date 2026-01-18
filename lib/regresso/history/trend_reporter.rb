# frozen_string_literal: true

require "erb"

module Regresso
  module History
    # Generates an HTML trend report for stored results.
    class TrendReporter
      # @param store [Regresso::History::Store]
      def initialize(store)
        @store = store
      end

      # @param period [Symbol]
      # @return [String] HTML report
      def generate(period: :week)
        stats = @store.statistics(period: period)
        template = <<~HTML
          <!doctype html>
          <html lang="en">
            <head>
              <meta charset="utf-8">
              <title>Regresso Trends</title>
              <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
              <style>
                body { font-family: Arial, sans-serif; padding: 20px; }
                .chart { max-width: 800px; margin: 32px auto; }
              </style>
            </head>
            <body>
              <h1>Regresso Trends</h1>
              <p>Total runs: <%= stats[:total_runs] %></p>
              <p>Success rate: <%= stats[:success_rate] %>%</p>

              <div class="chart">
                <canvas id="successChart"></canvas>
              </div>

              <script>
                const data = <%= JSON.generate(stats[:by_day]) %>;
                const labels = Object.keys(data);
                const successRates = labels.map(day => {
                  const dayData = data[day];
                  return dayData.total === 0 ? 0 : (dayData.passed / dayData.total * 100).toFixed(2);
                });

                new Chart(document.getElementById('successChart'), {
                  type: 'line',
                  data: {
                    labels: labels,
                    datasets: [{
                      label: 'Success Rate (%)',
                      data: successRates,
                      borderColor: '#1d4d9f',
                      backgroundColor: 'rgba(29, 77, 159, 0.2)'
                    }]
                  }
                });
              </script>
            </body>
          </html>
        HTML

        ERB.new(template).result(binding)
      end
    end
  end
end
