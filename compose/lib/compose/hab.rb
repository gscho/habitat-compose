# frozen_string_literal: true

module Compose
  module Hab
    # rubocop:disable Style/ClassVars
    @@hab_binary ||= ENV["PATH"].split(":")
                                .map { |path| File.join(path, "hab") }
                                .find { |path| File.exist?(path) }
    # rubocop:enable Style/ClassVars

    def hab(cmd, opts = {}, *args)
      env = opts.delete(:env) || {}
      timeout = opts.delete(:timeout) || 300
      work_dir = opts.delete(:work_dir)
      cmd = prepare_cmd(cmd, opts, args)

      Logger.debug "\nRunning command: '#{cmd.join(" ")}'" if opts[:verbose]

      process = POSIX::Spawn::Child.new(env, *(cmd + [{ chdir: work_dir, timeout: timeout.to_i }]))
      status = process.status
      [status.exitstatus, process.out, process.err]
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    def prepare_cmd(cmd, opts = {}, *args)
      args = args.first if args.size == 1 && args[0].is_a?(Array)
      args = args.map(&:to_s)
      options = opts.delete(:options) || []
      sub_command = opts.delete(:sub_command) || ""
      argv = []
      argv << @@hab_binary
      argv << cmd.to_s
      argv << sub_command
      argv.concat(options) unless options.empty?
      argv.concat(args)
      argv.reject(&:empty?)
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity

    def default_opts(opts)
      remote_sup = opts[:remote_sup] || "127.0.0.1:9632"
      verbose = opts[:verbose] || false
      [remote_sup, verbose]
    end

    def hab_stream(cmd, opts = {}, *args)
      work_dir = opts.delete(:work_dir) || "."
      exit_status = 0
      stdout, stderr = nil
      cmd = prepare_cmd(cmd, opts, args).join(" ")
      Open3.popen2e(cmd, chdir: work_dir) do |stdin, stdout_stderr, wait_thread|
        stdin.close_write
        Thread.new do
          stdout_stderr.each { |l| print l }
        end
        exit_status = wait_thread.value
      end
      [exit_status.exitstatus, stdout, stderr]
    end

    def hab_stdin(cmd, opts = {}, *args)
      stdin_str = opts.delete(:stdin) || ""
      exit_status = 0
      stdout, stderr = nil
      cmd = prepare_cmd(cmd, opts, args).join(" ")
      Open3.popen3(cmd) do |stdin, _stdout, _stderr, wait_thread|
        stdin.puts stdin_str
        stdin.close_write
        exit_status = wait_thread.value
      end

      [exit_status.exitstatus, stdout, stderr]
    end

    def hab_pkg_build(_pkg, opts = {})
      work_dir = opts.delete(:work_dir) || "."
      hab_stream(
        :pkg,
        {
          sub_command: "build",
          options: [],
          work_dir: work_dir
        },
        "."
      )
    end

    def hab_svc_load(pkg, opts = {})
      remote_sup, verbose = default_opts(opts)
      load_args = opts[:load_args] || []
      exitcode, stdout, stderr = hab(
        :svc,
        {
          sub_command: "load",
          options: load_args.append("--remote-sup=#{remote_sup}"),
          verbose: verbose
        },
        pkg
      )
      wait_for { svc_loaded?(pkg, remote_sup: remote_sup, verbose: verbose) } unless exitcode.positive?
      [exitcode, stdout, stderr]
    end

    def hab_svc_start(pkg, opts = {})
      remote_sup, verbose = default_opts(opts)
      load_args = opts[:load_args] || []
      exitcode, stdout, stderr = hab(
        :svc,
        {
          sub_command: "start",
          options: load_args.append("--remote-sup=#{remote_sup}"),
          verbose: verbose
        },
        pkg
      )
      wait_for { svc_up?(pkg, remote_sup: remote_sup, verbose: verbose) } unless exitcode.positive?
      [exitcode, stdout, stderr]
    end

    def hab_svc_unload(pkg, opts = {})
      remote_sup, verbose = default_opts(opts)
      options = []
      exitcode, stdout, stderr = hab(
        :svc,
        {
          sub_command: "unload",
          options: options.append("--remote-sup=#{remote_sup}"),
          verbose: verbose
        },
        pkg
      )
      wait_for { svc_unloaded?(pkg, remote_sup: remote_sup, verbose: verbose) } unless exitcode.positive?
      [exitcode, stdout, stderr]
    end

    def hab_svc_stop(pkg, opts = {})
      remote_sup, verbose = default_opts(opts)
      load_args = opts[:load_args] || []
      exitcode, stdout, stderr = hab(
        :svc,
        {
          sub_command: "stop",
          options: load_args.append("--remote-sup=#{remote_sup}"),
          verbose: verbose
        },
        pkg
      )
      wait_for { svc_down?(pkg, remote_sup: remote_sup, verbose: verbose) } unless exitcode.positive?
      [exitcode, stdout, stderr]
    end

    def hab_svc_status(opts = {})
      remote_sup, verbose = default_opts(opts)
      pkg = opts[:pkg] || nil
      exitcode, stdout, stderr = hab(
        :svc,
        {
          sub_command: "status",
          options: ["--remote-sup=#{remote_sup}"],
          verbose: verbose
        },
        pkg
      )
      [exitcode, stdout, stderr]
    end

    def hab_config_apply(pkg, opts = {})
      remote_sup, verbose = default_opts(opts)
      load_args = opts[:load_args] || []
      name = pkg.split("/")[1]
      group = group_from_load_args(load_args)
      config_toml = opts[:config_toml] || ""
      exitcode, stdout, stderr = hab_stdin(
        :config,
        {
          sub_command: "apply",
          options: ["--remote-sup=#{remote_sup}"],
          stdin: config_toml.to_s,
          verbose: verbose
        },
        "#{name}.#{group} #{Time.new.strftime("%s")}"
      )
      [exitcode, stdout, stderr]
    end

    def group_from_load_args(load_args)
      load_args.each do |arg|
        return arg.split("=")[-1] if arg.start_with?("--group")
      end
      "default"
    end

    def svc_loaded?(pkg, opts = {})
      remote_sup, verbose = default_opts(opts)
      _exitcode, stdout, _stderr = hab(
        :svc,
        {
          sub_command: "status",
          options: ["--remote-sup=#{remote_sup}"],
          verbose: verbose
        },
        pkg
      )

      !(stdout =~ /#{Regexp.quote(pkg)}/).nil?
    end

    def svc_up?(pkg, opts = {})
      remote_sup, verbose = default_opts(opts)
      _exitcode, stdout, _stderr = hab(
        :svc,
        {
          sub_command: "status",
          options: ["--remote-sup=#{remote_sup}"],
          verbose: verbose
        },
        pkg
      )

      stdout.scan(/up/).size == 2
    end

    def svc_unloaded?(pkg, opts = {})
      svc_loaded?(pkg, opts) == false
    end

    def svc_down?(pkg, opts = {})
      remote_sup, verbose = default_opts(opts)
      _exitcode, stdout, _stderr = hab(
        :svc,
        {
          sub_command: "status",
          options: ["--remote-sup=#{remote_sup}"],
          verbose: verbose
        },
        pkg
      )

      stdout.scan(/down/).size == 2
    end

    def wait_for(&block)
      loop do
        break if block.call

        sleep 2
      end
    end
  end
end
