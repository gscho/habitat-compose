# frozen_string_literal: true

module Compose
  module Commands
    class Stop < Base
      def exec
        each_svc do |name, defn|
          print_stoping(name, @name_offset) do
            hab_svc_stop(defn["pkg"], remote_sup: @remote_sup, verbose: @verbose)
          end
        end
      end
    end
  end
end
