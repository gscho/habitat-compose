module Compose
  module Commands
    class Down < Base
      def exec
        each_svc do |name, defn|
          hab_test("svc unload", nil, defn["pkg"])
        end
      end
    end
  end
end