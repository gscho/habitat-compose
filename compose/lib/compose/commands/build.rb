module Compose
  module Commands
    class Build
      include Hab

      def initialize(opts = {})
        @yaml = Commands.load_compose_file(opts["file"])
        init!
      end

      def exec
        built_pkgs = {}
        @plans_to_build.each do |svc,v|
          hab_test("pkg build", nil, v)
          last_build = File.read("/Users/greg.schofield/workspace/gscho/simple-go-app/results/last_build.env")
          last_build.split("\n").each do |line|
            s = line.split("=")
            built_pkgs[svc] = s[-1] if s[0].eql? "pkg_ident"
          end
        end
        built_pkgs
      end

      private

      def init!
        @plans_to_build = {}
        @yaml["services"].each_key do |svc|
          if @yaml["services"][svc]["build"]
            if @yaml["services"][svc]["build"].is_a? String
              @plans_to_build << @yaml["services"][svc]["build"]
            else
              @plans_to_build[svc] = @yaml["services"][svc]["build"]["context"]
            end
          end
        end
      end
    end
  end
end