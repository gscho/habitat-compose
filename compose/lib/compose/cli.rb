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
    desc "down", "Unload services"
    def down
      down = Compose::Commands::Down.new(options)
      down.exec
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

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "restart", "Restart services"
    def restart
      restart = Compose::Commands::Restart.new(options)
      restart.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "start", "Start services"
    def start
      start = Compose::Commands::Start.new(options)
      start.exec
    end

    desc "status", "View supervisor status"
    def status
      hab("svc status")
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "stop", "Stop services"
    def stop
      stop = Compose::Commands::Stop.new(options)
      stop.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "up", "Load services"
    def up
      up = Compose::Commands::Up.new(options)
      up.exec
    end

    desc "verison", "Display version information"
    def version
      STDOUT.puts Compose::VERSION
    end
  end
end