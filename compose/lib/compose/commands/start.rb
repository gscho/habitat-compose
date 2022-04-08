# frozen_string_literal: true

module Compose
  module Commands
    class Start < Base
      def exec
        each_svc(include_deps: true) do |name, defn|
          print_starting(name, @name_offset) do
            hab_svc_start(defn["pkg"], remote_sup: @remote_sup, verbose: @verbose)
          end
        end
      end
    end
  end
end
