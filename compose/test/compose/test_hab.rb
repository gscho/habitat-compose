# frozen_string_literal: true

require "test_helper"

class TestHab < Minitest::Test
  include Compose::Hab
  def test_prepare_command
    opts = {
      options: ["--remote-sup=33.33.33.33:9632", "--group=test"],
      verbose: false,
      sub_command: "load"
    }
    cmd = prepare_cmd(:svc, opts, ["core/redis"])

    assert_equal(%W[#{@@hab_binary} svc load --remote-sup=33.33.33.33:9632 --group=test core/redis], cmd)
  end

  def test_default_opts
    assert_equal(["127.0.0.1:9632", false], default_opts({}))
    opts = {
      remote_sup: "33.33.33.33:9632",
      verbose: true
    }
    remote_sup, verbose = default_opts(opts)
    assert_equal("33.33.33.33:9632", remote_sup)
    assert_equal(true, verbose)
  end

  def test_prepare_command_no_opts
    cmd = prepare_cmd(:svc, {}, ["core/redis"])
    assert_equal(%W[#{@@hab_binary} svc core/redis], cmd)
  end

  def test_group_from_load_args
    load_args = ["--group=default"]
    group = group_from_load_args(load_args)
    assert_equal("default", group)

    load_args = ["--group=prod", "--group=test"]
    group = group_from_load_args(load_args)
    assert_equal("prod", group)

    load_args = ["--channel=stable"]
    group = group_from_load_args(load_args)
    assert_equal("default", group)
  end
end
