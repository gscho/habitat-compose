module Compose
  module Commands
    class Base
      include Hab
      attr_accessor :yaml, :svcs, :pkg_builds

      def initialize(opts = {})
        @service_name = opts["service_name"]
        @yaml = load_compose_file(opts["file"])
      end

      def load_compose_file(path)
        YAML.load_file(path)
      end

      def built_pkg_name(context)
        last_build = File.read("#{context}/results/last_build.env")
        last_build.split("\n").each do |line|
          s = line.split("=")
          return s[-1] if s[0].eql? "pkg_name"
        end
      end
      
      def built_pkg_ident(context)
        last_build = File.read("#{context}/results/last_build.env")
        last_build.split("\n").each do |line|
          s = line.split("=")
          return s[-1] if s[0].eql? "pkg_ident"
        end
      end

      def each_svc
        @yaml["services"].tap do |services|
          services.each do |name, defn|
            next unless @service_name.eql?("") || @service_name.eql?(name)

            if defn["build"]
              if defn["build"].is_a? String
                defn["pkg"] = built_pkg_name(defn["build"])              
              else
                defn["pkg"] = built_pkg_name(defn["build"]["plan_context"])
              end
            end
            yield(name, defn)
          end
        end
      end

      def each_pkg_build
        @yaml["services"].tap do |services|
          services.each do |name, defn|
            next unless @service_name.eql?("") || @service_name.eql?(name)

            if defn["build"]
              yield(name, defn)
            elsif @service_name.eql?(name)
              STDOUT.puts "#{@service_name} uses a pre-built pkg, skipping"
            end
          end
        end
      end
    end
  end
end