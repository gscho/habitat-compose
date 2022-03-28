module Compose
  module Commands
    class Up < Base
      def exec
        each_svc do |name, defn|
          print_loading(name, @name_offset) do
            hab_svc_load(defn["pkg"], load_args: defn["load_args"], remote_sup: @remote_sup, verbose: @verbose)
          end
        end
      end
    end
  end
end