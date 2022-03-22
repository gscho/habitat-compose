module Compose
  module Commands
    class Up < Base
      def exec
        each_svc do |name, defn|
          options = defn["load_args"].join(" ") if defn["load_args"]
          hab_test("svc load", options, defn["pkg"])
        end
      end
    end
  end
end