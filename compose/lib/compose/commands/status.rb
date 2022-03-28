# frozen_string_literal: true

module Compose
  module Commands
    class Status < Base
      def exec
        if @service_name.empty?
          _exitcode, stdout, stderr = hab_svc_status(remote_sup: @remote_sup, verbose: @verbose)
        else
          each_svc do |name, defn|
            _exitcode, stdout, stderr = hab_svc_status(pkg: defn["pkg"], remote_sup: @remote_sup, verbose: @verbose)
          end
        end
        STDOUT.puts stdout
      end
    end
  end
end