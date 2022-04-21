# frozen_string_literal: true

require "test_helper"

class TestBase < Minitest::Test
  def setup
    compose_file = File.expand_path("../../fixtures/habitat-compose.yml", __dir__)
    opts = { "file" => compose_file }
    @base = Compose::Commands::Base.new(opts)
  end

  def test_built_pkg_ident
    context = File.expand_path("../../fixtures", __dir__)
    ident = @base.built_pkg_ident(context)
    assert_equal("gscho/simple-go-app/0.1.0/20220418181553", ident)
  end

  def test_validate_toml_good
    toml = <<-TOML
    [table]
    str = "foo"
    int = 9
    multi = """
    test
    """
    TOML
    refute_nil(@base.validate_toml(toml))
  end

  def test_validate_toml_bad
    toml = <<-TOML
    [table] = this is bad":
    TOML
    assert_raises do
      @base.validate_toml(toml)
    end
  end

  def test_each_svc_no_deps
    compose_file = File.expand_path("../../fixtures/habitat-compose.yml", __dir__)
    opts = { "file" => compose_file, "service_name" => "webapp" }
    svcs = []
    base_with_service_name = Compose::Commands::Base.new(opts)
    base_with_service_name.each_svc(include_deps: false) { |name, _defn| svcs << name }
    assert_equal(%w[webapp], svcs)
  end

  def test_each_svc_deps
    compose_file = File.expand_path("../../fixtures/habitat-compose.yml", __dir__)
    opts = { "file" => compose_file, "service_name" => "webapp" }
    svcs = []
    base_with_service_name = Compose::Commands::Base.new(opts)
    base_with_service_name.each_svc(include_deps: true) { |name, _defn| svcs << name }
    assert_equal(%w[redis db webapp], svcs)
  end

  def test_service_deps
    expected = {
      webapp: %i[db redis],
      redis: [],
      db: [:redis]
    }
    actual = @base.service_deps
    assert_equal(expected, actual)
  end

  def test_order_services
    expected = %w[redis db webapp]
    actual = @base.order_services.keys
    assert_equal(expected, actual)
  end

  def test_each_pkg_build
    compose_file = File.expand_path("../../fixtures/habitat-compose.yml", __dir__)
    opts = { "file" => compose_file, "service_name" => "webapp" }
    svcs = []
    base_with_service_name = Compose::Commands::Base.new(opts)
    base_with_service_name.each_pkg_build { |name, _defn| svcs << name }
    assert_equal(%w[webapp], svcs)
  end
end
