require "thor"

module Compose
  class CLI < Thor
    include Hab
    class_option :verbose, desc: "Show more output from command", required: false, type: :boolean

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "build [SERVICE_NAME]", "Build or rebuild packages"
    def build(service_name = "")
      opts = options.dup
      opts["service_name"] = service_name
      build = Compose::Commands::Build.new(opts)
      build.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "down [SERVICE_NAME]", "Unload services"
    def down(service_name = "")
      opts = options.dup
      opts["service_name"] = service_name
      down = Compose::Commands::Down.new(opts)
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
    desc "restart [SERVICE_NAME]", "Restart services"
    def restart(service_name = "")
      opts = options.dup
      opts["service_name"] = service_name
      restart = Compose::Commands::Restart.new(opts)
      restart.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "start [SERVICE_NAME]", "Start services"
    def start(service_name = "")
      opts = options.dup
      opts["service_name"] = service_name
      start = Compose::Commands::Start.new(opts)
      start.exec
    end

    desc "status", "View supervisor status"
    def status
      hab("svc status")
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "stop [SERVICE_NAME]", "Stop services"
    def stop(service_name = "")
      opts = options.dup
      opts["service_name"] = service_name
      stop = Compose::Commands::Stop.new(opts)
      stop.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "up [SERVICE_NAME]", "Load services"
    def up(service_name = "")
      opts = options.dup
      opts["service_name"] = service_name
      up = Compose::Commands::Up.new(opts)
      up.exec
    end

    desc "verison", "Display version information"
    def version
      STDOUT.puts Compose::VERSION
    end
  end
end