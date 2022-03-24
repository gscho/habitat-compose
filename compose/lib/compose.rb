# frozen_string_literal: true

require "paint"

require_relative "compose/hab"
require_relative "compose/cli"
require_relative "compose/commands"
require_relative "compose/version"

module Compose
  class Error < StandardError; end
end
