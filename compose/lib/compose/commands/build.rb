# frozen_string_literal: true

module Compose
  module Commands
    class Build < Base
      def exec
        each_pkg_build do |name, defn|
          plan_context = if defn["build"].is_a? String
                           defn["build"]
                         else
                           defn["build"]["plan_context"]
                         end
          hab_pkg_build(defn["pkg"], work_dir: plan_context, remote_sup: @remote_sup, verbose: @verbose)
        end
      end
    end
  end
end
