module Compose
  class CLI < Thor
    include Hab
    class_option :verbose, desc: "Show more output from command", required: false, type: :boolean
    class_option :remote_sup, desc: "Address to a remote Supervisor's Control Gateway", required: false, type: :string, default: "127.0.0.1:9632"
    
    no_commands do
      def to_opts(service_name, options)
        opts = options.dup
        opts["service_name"] = service_name
        opts
      end

      def tail_dash_f(filename)
        open(filename) do |file|
          puts file.read
          case RUBY_PLATFORM   # string with OS name, like "amd64-freebsd8"
          when /bsd/, /darwin/
            require 'rb-kqueue'
            queue = KQueue::Queue.new     
            queue.watch_file(filename, :extend) do
              yield file.read             
            end
            queue.run                     
          when /linux/
            require 'rb-inotify'
            queue = INotify::Notifier.new  
            queue.watch(filename, :modify) do
              yield file.read             
            end
            queue.run                      
          else
            loop do           
              changes = file.read
              unless changes.empty?  
                yield changes
              end
              sleep 1.0       
            end
          end
        end
      end
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "build [SERVICE_NAME]", "Build or rebuild packages"
    def build(service_name = "")
      build = Compose::Commands::Build.new(to_opts(service_name, options))
      build.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "down [SERVICE_NAME]", "Unload services"
    def down(service_name = "")
      down = Compose::Commands::Down.new(to_opts(service_name, options))
      down.exec
    end

    option :follow, desc: "Follow log output", aliases: "-f", type: :boolean, default: false, required: false
    desc "logs [SERVICE_NAME]", "View supervisor logs"
    def logs(service_name = "")
      if options["follow"]
        tail_dash_f("../default/sup.log") do |data|
          print data
          if data =~ /error/i
            # do something else, for example send an email to administrator
          end
        end
      else
        File.readlines("../default/sup.log").each do |line|
          puts(line)
        end
      end
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "restart [SERVICE_NAME]", "Restart services"
    def restart(service_name = "")
      down = Compose::Commands::Down.new(to_opts(service_name, options))
      down.exec
      up = Compose::Commands::Up.new(to_opts(service_name, options))
      up.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "start [SERVICE_NAME]", "Start services"
    def start(service_name = "")
      start = Compose::Commands::Start.new(to_opts(service_name, options))
      start.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "status [SERVICE_NAME]", "View supervisor status"
    def status(service_name = "")
      status = Compose::Commands::Status.new(to_opts(service_name, options))
      status.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    desc "stop [SERVICE_NAME]", "Stop services"
    def stop(service_name = "")
      stop = Compose::Commands::Stop.new(to_opts(service_name, options))
      stop.exec
    end

    option :file, desc: "Specify an alternate compose file", aliases: "-f", required: false, default: "habitat-compose.yml"
    option :build, desc: "Build packages before loading them", required: false, type: :boolean
    desc "up [SERVICE_NAME]", "Load services"
    def up(service_name = "")
      build(service_name) if options["build"]

      up = Compose::Commands::Up.new(to_opts(service_name, options))
      up.exec
    end

    desc "verison", "Display version information"
    def version
      STDOUT.puts Compose::VERSION
    end
  end
end