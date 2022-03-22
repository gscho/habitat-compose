require "open3"

module Compose
  module Hab
    @@hab_binary ||= ENV['PATH'].split(':')
                                 .map { |path| File.join(path, 'hab') }
                                 .find { |path| File.exist?(path) }
    
    def hab(cmd, opts = nil, arg = nil)
      # if opts && opts["plan_context"]
      #   `cd #{opts["plan_context"]} && #{@@hab_binary} #{cmd} #{opts} #{arg}`.squeeze(" ")
      # else
      #   `#{@@hab_binary} #{cmd} #{opts} #{arg}`.squeeze(" ")
      # end
      cmd = "#{@@hab_binary} #{cmd}"
      Open3.popen2e(cmd, opts) do |stdin, stdout_and_stderr, wait_thread|
        pid = wait_thread.pid
        stdout_and_stderr.each {|l| puts l }
      end
    end
    
    def hab_test(cmd, opts = nil, arg = nil)
      # if opts && opts["plan_context"]
      #   puts "cd #{opts["plan_context"]} && #{@@hab_binary} #{cmd} #{opts} #{arg}".squeeze(" ")
      # else
        puts "#{@@hab_binary} #{cmd} #{opts} #{arg}".squeeze(" ")
      # end
    end
  end
end