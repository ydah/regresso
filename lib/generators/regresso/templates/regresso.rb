# frozen_string_literal: true

Regresso.configure do |config|
  # Default numeric tolerance for comparisons
  config.default_tolerance = 0.0

  # Paths to ignore (String or Regexp)
  config.ignore_paths = []

  # Per-path tolerance overrides
  config.tolerance_overrides = {}

  # Array order sensitivity
  config.array_order_sensitive = true

  # Type coercion for numeric comparison
  config.type_coercion = true
end
