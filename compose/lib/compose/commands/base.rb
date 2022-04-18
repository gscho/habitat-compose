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
        deps = service_deps
        ordered_services(deps).each do |name, defn|
          next unless service_name_match?(name) || (include_deps && service_dep?(deps, name))

          defn["pkg"] = get_built_pkg_name(defn) if defn["build"]
          yield(name, defn)
        end
      end

      def service_deps
        deps = {}
        @yaml["services"].each do |name, defn|
          defn["depends_on"] = [] unless defn["depends_on"]

          deps[name.to_sym] = defn["depends_on"].map(&:to_sym)
          @name_offset = name.size if name.size > @name_offset
        end
        deps
      end

      def ordered_services(deps)
        services = {}
        graph = Dagwood::DependencyGraph.new(deps)
        graph.order.each do |k|
          services[k.to_s] = @yaml["services"][k.to_s]
        end
        services
      end

      def service_name_match?(current)
        @service_name.eql?("") || @service_name.eql?(current)
      end

      def service_dep?(deps, current)
        deps[@service_name.to_sym]&.include?(current.to_sym)
      end

      def get_built_pkg_name(defn)
        context = defn["build"].is_a?(String) ? defn["build"] : defn["build"]["plan_context"]
        built_pkg_name(context)
      end

      def each_pkg_build
        @yaml["services"].tap do |services|
          services.each do |name, defn|
            next unless @service_name.eql?("") || @service_name.eql?(name)

            if defn["build"]
              yield(name, defn)
            elsif @service_name.eql?(name)
              $stdout.puts "#{@service_name} uses a pre-built pkg, skipping"
            end
          end
        end
      end
    end
  end
end
