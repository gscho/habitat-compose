# frozen_string_literal: true

module Compose
  module ScreenOutput
    def print_loading(name, offset)
      load_line = "Loading #{name.ljust(offset)}    ... "
      print load_line
      _exitcode, stdout, stderr = yield
      
      up_to_date = "\r#{name} is up-to-date"
      (load_line.size - up_to_date.size).times {|_| up_to_date.concat(" ") }
      print up_to_date + "\n" if stderr =~ /Service already loaded/
      print Paint["done\n", :green] if stderr.eql?("")
    end

    def print_unloading(name, pkg, offset)
      unload_line = "Unloading #{name.ljust(offset)}  ... "
      print unload_line
      _exitcode, stdout, stderr = yield
      
      not_loaded = "\r#{name} is not loaded"
      (unload_line.size - not_loaded.size).times {|_| not_loaded.concat(" ") }
      print not_loaded + "\n" if stderr =~ /Service #{Regexp.quote(pkg)} not loaded/
      print Paint["done\n", :green] if stderr.eql?("")
    end
  end
end