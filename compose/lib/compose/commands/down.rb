module Compose
  module Commands
    class Down < Base
      def exec
        each_svc do |name, defn|
          load_line = "Unloading #{name.ljust(@name_offset)}  ... "
          print load_line
          options = []
          _exitcode, stdout, stderr = hab(
            :svc, 
            {
              sub_command: "unload",
              options: options.append("--remote-sup=#{@remote_sup}"),
              verbose: @verbose
            }, 
            defn["pkg"]
          )
          not_loaded = "\r#{name} is not loaded"
          (load_line.size - not_loaded.size).times {|_| not_loaded.concat(" ") }
          print not_loaded + "\n" if stderr =~ /Service #{Regexp.quote(defn["pkg"])} not loaded/
          print Paint["done\n", :green] if stderr.eql?("")
        end
      end
    end
  end
end