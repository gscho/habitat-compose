module Compose
  module Hab
    # rubocop:disable Style/ClassVars
    @@hab_binary ||= ENV['PATH'].split(':')
                                 .map { |path| File.join(path, 'hab') }
                                 .find { |path| File.exist?(path) }
    # rubocop:enable Style/ClassVars
    def hab(cmd, opts = nil, arg = nil)
      `cd /Users/greg.schofield/workspace/gscho/simple-go-app && #{@@hab_binary} #{cmd} #{opts} #{arg}`
    end
    
    def hab_test(cmd, opts = nil, arg = nil)
      puts "#{@@hab_binary} #{cmd} #{opts} #{arg}".squeeze(" ")
    end
  end
end