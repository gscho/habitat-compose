module Compose
  module Commands
    class Stop < Base
      def exec
        each_svc do |name, defn|
          hab_test("svc stop", nil, defn["pkg"])
        end
      end
    end
  end
end