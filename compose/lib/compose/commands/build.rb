module Compose
  module Commands
    class Build < Base
      def exec
        built_pkgs = {}
        each_pkg_build do |name,defn|
          opts = {}
          if defn["build"].is_a? String
            opts["plan_context"] = defn["build"]
          else
            opts["plan_context"] = defn["build"]["plan_context"]
          end
          hab_test("pkg build", opts, ".")          
          built_pkgs[name] = built_pkg_ident("/Users/greg.schofield/workspace/gscho/simple-go-app")
        end
        built_pkgs
      end
    end
  end
end