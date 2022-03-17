require "yaml"
require_relative "commands/build"

module Compose
  module Commands
    
    def self.load_compose_file(path)
      YAML.load_file(path)
    end
  end
end