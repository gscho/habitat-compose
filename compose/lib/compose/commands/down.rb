# frozen_string_literal: true

module Compose
  module Commands
    class Down < Base
      def exec
        each_svc do |name, defn|
          print_unloading(name, defn["pkg"], @name_offset) do
            hab_svc_unload(defn["pkg"], remote_sup: @remote_sup, verbose: @verbose)
          end
        end
      end
    end
  end
end