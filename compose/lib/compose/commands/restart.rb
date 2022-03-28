# frozen_string_literal: true

module Compose
  module Commands
    class Restart < Base
      def exec
        each_svc do |name, defn|
          hab_test("svc stop", nil, defn["pkg"])
          hab_test("svc start", nil, defn["pkg"])
        end
      end
    end
  end
end