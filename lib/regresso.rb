# frozen_string_literal: true

require_relative "regresso/version"
require_relative "regresso/json_path"
require_relative "regresso/difference"
require_relative "regresso/configuration"
require_relative "regresso/differ"
require_relative "regresso/result"
require_relative "regresso/comparator"
require_relative "regresso/adapters/base"
require_relative "regresso/adapters/proc"
require_relative "regresso/adapters/json_file"
require_relative "regresso/adapters/csv"
require_relative "regresso/adapters/http"

module Regresso
  class Error < StandardError; end
end
