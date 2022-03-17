module Compose
  module Commands
    class Restart
      include Hab

      def initialize(opts = {})
        @yaml = Commands.load_compose_file(opts["file"])
        init!
      end

      def exec
        @services_to_restart.each do |svc|
          hab_test("svc stop", nil, svc)
          hab_test("svc start", nil, svc)
        end
      end

      private

      def init!
        @services_to_restart = []
        @yaml["services"].each_key do |svc|
          if @yaml["services"][svc]["build"]
            if @yaml["services"][svc]["build"].is_a? String
              @services_to_restart << Commands.built_pkg_name(@yaml["services"][svc]["build"])
            else
              @services_to_restart << Commands.built_pkg_name(@yaml["services"][svc]["build"]["context"])
            end
          else
            @services_to_restart << @yaml["services"][svc]["pkg"]
          end
        end
      end
    end
  end
end