module Compose
  module Commands
    class Status < Base
      def exec
        if @service_name.empty?
          _exitcode, stdout, stderr = hab(
            :svc,
            {
              sub_command: "status",
              options: ["--remote-sup=#{@remote_sup}"],
              verbose: @verbose
            }, 
            nil
          )
        else
          each_svc do |name, defn|
            _exitcode, stdout, stderr = hab(
              :svc, 
              {
                sub_command: "status",
                options: ["--remote-sup=#{@remote_sup}"],
                verbose: @verbose
              }, 
              defn["pkg"]
            )
          end
        end
        puts stdout
      end
    end
  end
end