require "yaml"
module Compose
  class CLI
    include Hab
    def initialize
      @yaml = YAML.load_file("./habitat-compose.yml")
      plans_to_build = {}
      load_args = {}
      pkgs = {}
      config_tomls = {}
      @yaml["services"].each_key do |svc|
        if @yaml["services"][svc]["build"]
          if @yaml["services"][svc]["build"].is_a? String
            plans_to_build << @yaml["services"][svc]["build"]
          else
            plans_to_build[svc] = @yaml["services"][svc]["build"]["context"]
          end
        end
        if @yaml["services"][svc]["load_args"]
          load_args[svc] = @yaml["services"][svc]["load_args"].join(" ")
        end
        if @yaml["services"][svc]["pkg"]
          pkgs[svc] = @yaml["services"][svc]["pkg"]
        end
        if @yaml["services"][svc]["config_toml"]
          config_tomls[svc] = @yaml["services"][svc]["config_toml"]
        end
      end
      plans_to_build.each do |k,v|
        hab_test("pkg build", nil, v)
        last_build = File.read("/Users/greg.schofield/workspace/gscho/simple-go-app/results/last_build.env")
        last_build.split("\n").each do |line|
          s = line.split("=")
          pkgs[k] = s[-1] if s[0].eql? "pkg_ident"
        end
      end
      
      pkgs.each do |svc, pkg|
        origin, name, version, ts = pkg.split("/")
        if config_tomls[svc]
          puts "mkdir -p /hab/user/#{name}/config"
          puts "touch /hab/user/#{name}/config/user.toml"
          puts "content="
          puts config_tomls[svc]
        end
        hab_test("svc load", load_args[svc], pkg)
      end
    end
  end
end