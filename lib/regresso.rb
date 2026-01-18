# frozen_string_literal: true

require_relative "regresso/version"
require_relative "regresso/json_path"
require_relative "regresso/difference"
require_relative "regresso/configuration"
require_relative "regresso/differ"
require_relative "regresso/result"
require_relative "regresso/comparator"

module Regresso
  class Error < StandardError; end
end
