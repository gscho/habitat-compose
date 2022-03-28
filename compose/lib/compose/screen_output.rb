module Compose
  module ScreenOutput
    def print_loading(name, offset)
      load_line = "Loading #{name.ljust(offset)}  ... "
      print load_line
      _exitcode, stdout, stderr = yield
      up_to_date = "\r#{name} is up-to-date"
      (load_line.size - up_to_date.size).times {|_| up_to_date.concat(" ") }
      print up_to_date + "\n" if stderr =~ /Service already loaded/
      print Paint["done\n", :green] if stderr.eql?("")
    end
  end
end