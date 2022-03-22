module Compose
  module Hab
    @@hab_binary ||= ENV['PATH'].split(':')
                                 .map { |path| File.join(path, 'hab') }
                                 .find { |path| File.exist?(path) }
    
    def hab(cmd, opts = nil, arg = nil)
      if opts && opts["plan_context"]
        `cd #{opts["plan_context"]} && #{@@hab_binary} #{cmd} #{opts} #{arg}`.squeeze(" ")
      else
        `#{@@hab_binary} #{cmd} #{opts} #{arg}`.squeeze(" ")
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