# frozen_string_literal: true

require "dagwood"
require "file-tail"
require "logger"
require "open3"
require "paint"
require "posix-spawn"
require "thor"
require "tomlrb"
require "yaml"

require_relative "compose/hab"
require_relative "compose/screen_output"
require_relative "compose/cli"
require_relative "compose/commands"
require_relative "compose/version"

module Compose
  class Error < StandardError; end
  Logger = Logger.new(STDOUT)
end
