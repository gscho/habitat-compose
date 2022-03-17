require "yaml"

require_relative "commands/build"
require_relative "commands/down"
require_relative "commands/restart"
require_relative "commands/start"
require_relative "commands/stop"
require_relative "commands/up"


module Compose
  module Commands
    def self.load_compose_file(path)
      YAML.load_file(path)
    end

    def self.built_pkg_name(context)
      last_build = File.read("#{context}/results/last_build.env")
      last_build.split("\n").each do |line|
        s = line.split("=")
        return s[-1] if s[0].eql? "pkg_name"
      end
    end
    
    def self.built_pkg_ident(context)
      last_build = File.read("#{context}/results/last_build.env")
      last_build.split("\n").each do |line|
        s = line.split("=")
        return s[-1] if s[0].eql? "pkg_ident"
      end
    end
  end
end