module Compose
  module Commands
    class Up < Base
      def exec
        each_svc do |name, defn|
          hab_test("svc load", nil, defn["pkg"])
        end
      end
    end
  end
end