# frozen_string_literal: true

module Compose
  class CLI < Thor
    include Hab
    class_option :verbose, desc: "Show more output from command", required: false, type: :boolean
    class_option :remote_sup, desc: "Address to a remote Supervisor's Control Gateway", required: false, type: :string,
                              default: "127.0.0.1:9632"

    no_commands do
      def to_opts(service_name, options)
        opts = options.dup
        opts["service_name"] = service_name
        opts
      end
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false,
                  default: "habitat-compose.yml"
    desc "build [SERVICE_NAME]", "Build or rebuild packages"
    def build(service_name = "")
      build = Compose::Commands::Build.new(to_opts(service_name, options))
      build.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false,
                  default: "habitat-compose.yml"
    desc "down [SERVICE_NAME]", "Unload services"
    def down(service_name = "")
      down = Compose::Commands::Down.new(to_opts(service_name, options))
      down.exec
    end

    option :follow, desc: "Follow log output", aliases: "-f", type: :boolean, default: false, required: false
    option :tail, desc: "Number of lines to show from the end of the logs for each service", aliases: "-t",
                  type: :string, default: "all", required: false
    option :log_file, desc: "Path to the supervisor log file", aliases: "-l", type: :string, 
                      default: "/hab/sup/default/sup.log", required: false
    desc "logs [SERVICE_NAME]", "View supervisor logs"
    def logs(service_name = "")
      logs = Compose::Commands::Logs.new(to_opts(service_name, options))
      logs.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false,
                  default: "habitat-compose.yml"
    desc "restart [SERVICE_NAME]", "Restart services"
    def restart(service_name = "")
      stop = Compose::Commands::Stop.new(to_opts(service_name, options))
      stop.exec
      start = Compose::Commands::Start.new(to_opts(service_name, options))
      start.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false,
                  default: "habitat-compose.yml"
    desc "reload [SERVICE_NAME]", "Reload services"
    def reload(service_name = "")
      down = Compose::Commands::Down.new(to_opts(service_name, options))
      down.exec
      up = Compose::Commands::Up.new(to_opts(service_name, options))
      up.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false,
                  default: "habitat-compose.yml"
    desc "start [SERVICE_NAME]", "Start services"
    def start(service_name = "")
      start = Compose::Commands::Start.new(to_opts(service_name, options))
      start.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false,
                  default: "habitat-compose.yml"
    desc "status [SERVICE_NAME]", "View supervisor status"
    def status(service_name = "")
      status = Compose::Commands::Status.new(to_opts(service_name, options))
      status.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false,
                  default: "habitat-compose.yml"
    desc "stop [SERVICE_NAME]", "Stop services"
    def stop(service_name = "")
      stop = Compose::Commands::Stop.new(to_opts(service_name, options))
      stop.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false,
                  default: "habitat-compose.yml"
    option :build, desc: "Build packages before loading them", required: false, type: :boolean, default: false
    option :config, desc: "Configure packages after loading them", required: false, type: :boolean, default: true
    desc "up [SERVICE_NAME]", "Load services"
    def up(service_name = "")
      build(service_name) if options["build"]

      up = Compose::Commands::Up.new(to_opts(service_name, options))
      up.exec
      config(service_name, true) if options["config"]
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false,
                  default: "habitat-compose.yml"
    desc "config [SERVICE_NAME]", "Sets a service configuration"
    def config(service_name = "", deps = false)
      config = Compose::Commands::Config.new(to_opts(service_name, options))
      config.exec(deps)
    end

    desc "verison", "Display version information"
    def version
      STDOUT.puts Compose::VERSION
    end
  end
end
