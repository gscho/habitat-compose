# frozen_string_literal: true

module Compose
  module ScreenOutput
    def print_loading(name, offset)
      load_line = "Loading #{name.ljust(offset)}    ... "
      print load_line
      exitcode, _stdout, stderr = yield

      up_to_date = "\r#{name} is up-to-date"
      (load_line.size - up_to_date.size).times { |_| up_to_date.concat(" ") }
      if stderr =~ /Service already loaded/
        print "#{up_to_date}\n"
      else
        print_result(exitcode, stderr)
      end
    end

    def print_starting(name, offset)
      load_line = "Starting #{name.ljust(offset)}    ... "
      print load_line
      exitcode, _stdout, stderr = yield
      print_result(exitcode, stderr)
    end

    def print_unloading(name, pkg, offset)
      unload_line = "Unloading #{name.ljust(offset)}  ... "
      print unload_line
      exitcode, _stdout, stderr = yield

      not_loaded = "\r#{name} is not loaded"
      (unload_line.size - not_loaded.size).times { |_| not_loaded.concat(" ") }
      if stderr =~ /Service #{Regexp.quote(pkg)} not loaded/
        print "#{not_loaded}\n"
      else
        print_result(exitcode, stderr)
      end
    end

    def print_configuring(name, offset)
      config_line = "Applying configuration to #{name.ljust(offset)}  ... "
      print config_line
      exitcode, _stdout, stderr = yield
      print_result(exitcode, stderr)
    end

    def print_stoping(name, offset)
      load_line = "Stopping #{name.ljust(offset)}    ... "
      print load_line
      exitcode, _stdout, stderr = yield
      print_result(exitcode, stderr)
    end

    def print_result(exitcode, stderr)
      if exitcode.positive?
        print Paint["error\n", :red]
        $stdout.puts stderr
      else
        print Paint["done\n", :green]
      end
    end
  end
end
