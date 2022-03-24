module Compose
  module Commands
    class Up < Base
      def exec
        each_svc do |name, defn|
          load_line = "Loading #{name.ljust(@name_offset)}  ... "
          print load_line
          options = defn.delete("load_args") || []
          _exitcode, stdout, stderr = hab(
            :svc, 
            {
              sub_command: "load",
              options: options.append("--remote-sup=#{@remote_sup}"),
              verbose: @verbose
            }, 
            defn["pkg"]
          )
          up_to_date = "\r#{name} is up-to-date"
          (load_line.size - up_to_date.size).times {|_| up_to_date.concat(" ") }
          print up_to_date + "\n" if stderr =~ /Service already loaded/
          print Paint["done\n", :green] if stderr.eql?("")
        end
      end
    end
  end
end