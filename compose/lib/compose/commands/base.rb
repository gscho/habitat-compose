# frozen_string_literal: true

module Compose
  module Commands
    class Base
      include Hab
      include ScreenOutput

      def initialize(opts = {})
        @service_name = opts["service_name"]
        @remote_sup = opts["remote_sup"]
        @verbose = opts["verbose"]
        @name_offset = 5
        @yaml = load_compose_file(opts["file"])
        @deps = service_deps
        @ordered_services = order_services
      end

      def load_compose_file(path)
        YAML.load_file(path)
      end

      def built_pkg_ident(context)
        if context.is_a?(Hash)
          context = context["build"].is_a?(String) ? context["build"] : context["build"]["plan_context"]
        end
        last_build = File.read("#{context}/results/last_build.env")
        last_build.split("\n").each do |line|
          s = line.split("=")
          return s[-1] if s[0].eql? "pkg_ident"
        end
      end

      def validate_toml(toml)
        Tomlrb.parse(toml)
      rescue Tomlrb::ParseError
        print "\n"
        $stdout.puts "Error parsing the toml:"
        $stdout.puts toml
        raise
      end

      def each_svc(include_deps: false)
        @ordered_services.each do |name, defn|
          next unless service_name_match?(name) || (include_deps && service_dep?(name))

          defn["pkg"] = built_pkg_ident(defn) if defn["build"]
          yield(name, defn) if block_given?
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

      def order_services
        services = {}
        graph = Dagwood::DependencyGraph.new(@deps)
        graph.order.each do |k|
          services[k.to_s] = @yaml["services"][k.to_s]
        end
        services
      end

      def service_name_match?(current)
        @service_name.eql?("") || @service_name.eql?(current)
      end

      def service_dep?(current)
        @deps[@service_name.to_sym]&.include?(current.to_sym)
      end

      def each_pkg_build
        @yaml["services"].tap do |services|
          services.each do |name, defn|
            next unless service_name_match?(name)

            if defn["build"]
              yield(name, defn) if block_given?
            elsif @service_name.eql?(name)
              $stdout.puts "#{@service_name} uses a pre-built pkg, skipping"
            end
          end
        end
      end
    end
  end
end
