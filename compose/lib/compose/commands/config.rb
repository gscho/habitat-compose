# frozen_string_literal: true

module Compose
  module Commands
    class Config < Base
      def exec(deps: false)
        each_svc(include_deps: deps) do |name, defn|
          next unless defn["config_toml"]

          print_configuring(name, @name_offset) do
            validate_toml(defn["config_toml"])
            hab_config_apply(defn["pkg"], config_toml: defn["config_toml"], load_args: defn["load_args"],
                                          remote_sup: @remote_sup, verbose: @verbose)
          end
        end
      end
    end
  end
end
