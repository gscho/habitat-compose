# frozen_string_literal: true

module Compose
  module Commands
    class Base
      include Hab
      include ScreenOutput
      attr_accessor :yaml, :svcs, :pkg_builds

      def initialize(opts = {})
        @service_name = opts["service_name"]
        @remote_sup = opts["remote_sup"]
        @verbose = opts["verbose"]
        @name_offset = 5
        @yaml = load_compose_file(opts["file"])
      end

      def load_compose_file(path)
        YAML.load_file(path)
      end

      def built_pkg_name(context)
        pkg_ident = built_pkg_ident(context)
        return unless pkg_ident

        pkg_ident
      end

      def built_pkg_ident(context)
        last_build = File.read("#{context}/results/last_build.env")
        last_build.split("\n").each do |line|
          s = line.split("=")
          return s[-1] if s[0].eql? "pkg_ident"
        end
      end

      def validate_toml(toml)
        Tomlrb.parse(toml)
      end

      def each_svc(opts = {})
        include_deps = opts.delete(:include_deps) || false
        services = {}
        deps = {}
        @yaml["services"].each do |name, defn|
          defn["depends_on"] = [] unless defn["depends_on"]

          deps[name.to_sym] = defn["depends_on"].map(&:to_sym)
          @name_offset = name.size if name.size > @name_offset
        end

        graph = Dagwood::DependencyGraph.new(deps)
        graph.order.each do |k|
          services[k.to_s] = @yaml["services"][k.to_s]
        end

        services.each do |name, defn|
          unless @service_name.eql?("") || @service_name.eql?(name) || (deps[@service_name.to_sym] && deps[@service_name.to_sym].include?(name.to_sym) && include_deps)
            next
          end

          if defn["build"]
            defn["pkg"] = if defn["build"].is_a? String
                            built_pkg_name(defn["build"])
                          else
                            built_pkg_name(defn["build"]["plan_context"])
                          end
          end
          yield(name, defn)
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
