require "posix-spawn"

module Compose
  module Hab
    @@hab_binary ||= ENV['PATH'].split(':')
                                 .map { |path| File.join(path, 'hab') }
                                 .find { |path| File.exist?(path) }
    
    def hab(cmd, opts = {}, *args)
      args = args.first if args.size == 1 && args[0].is_a?(Array)
      args = args.map(&:to_s).reject(&:empty?)
      env = opts.delete(:env) || {}
      timeout = opts.delete(:timeout) || 300
      options = opts.delete(:options) || []
      sub_command = opts.delete(:sub_command)
      # args.unshift(sub_command)
      work_dir = opts.delete(:work_dir)
      argv = []
      argv << @@hab_binary
      argv << cmd.to_s
      argv << sub_command
      argv.concat(options) unless options.empty?
      argv.concat(args)
      STDOUT.puts "Running command: '#{argv.join(" ")}'" if opts[:verbose]

      process = POSIX::Spawn::Child.new(env, *(argv + [{ chdir: work_dir, timeout: timeout.to_i }]))
      status = process.status
      [status.exitstatus, process.out, process.err]
      # Open3.popen2e(cmd, opts) do |stdin, stdout_and_stderr, wait_thread|
      #   pid = wait_thread.pid
      #   stdout_and_stderr.each {|l| puts l }
      # end
    end
    
    def hab_test(cmd, opts = nil, arg = nil)
      # if opts && opts["plan_context"]
      #   puts "cd #{opts["plan_context"]} && #{@@hab_binary} #{cmd} #{opts} #{arg}".squeeze(" ")
      # else
        puts "#{@@hab_binary} #{cmd} #{opts} #{arg}".squeeze(" ")
      # end
    end

    def svc_loaded?(pkg, opts = {})
      remote_sup = opts[:remote_sup] || "127.0.0.1:9632"
      verbose = opts[:verbose] || false
      _exitcode, statusout, statuserr = hab(
        :svc,
        {
          sub_command: "status",
          options: ["--remote-sup=#{remote_sup}"],
          verbose: verbose
        }, 
        pkg
      )
      
      !(statusout =~ /#{Regexp.quote(pkg)}/).nil?
    end

    def svc_unloaded?(pkg, opts = {})
      svc_loaded?(pkg, opts) == false
    end

    def wait_for_svc_up(pkg, opts = {})
      loop do
        break if svc_loaded?(pkg, opts)

        sleep 2
      end
    end

    def wait_for_svc_down(pkg, opts = {})
      loop do
        break if svc_unloaded?(pkg, opts)

        sleep 2
      end
    end
  end
end