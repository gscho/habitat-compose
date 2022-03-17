require "thor"

module Compose
  class CLI < Thor
    include Hab
    class_option :verbose, desc: "Show more output from command", required: false, type: :boolean

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "build", "Build or rebuild packages"
    def build
      build = Compose::Commands::Build.new(options)
      build.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "up", "Load services"
    def up
      puts "up"
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "down", "Unload services"
    def down
      puts "down"
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "restart", "Restart services"
    def restart
      puts "restart"
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "start", "Start services"
    def start
      puts "start"
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "stop", "Stop services"
    def stop
      puts "stop"
    end

    option :follow, desc: "Follow log output", aliases: "-f", type: :boolean, default: false, required: false
    desc "logs", "View supervisor logs"
    def logs
      if options["follow"]
        `tail -f /hab/sup/default/sup.log`
      else
        `cat /hab/sup/default/sup.log`
      end
    end

    desc "status", "View supervisor status"
    def status
      hab("svc status")
    end

    desc "verison", "Display version information"
    def version
      STDOUT.puts Compose::VERSION
    end
  end
end