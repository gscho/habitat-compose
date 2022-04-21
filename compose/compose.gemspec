# frozen_string_literal: true

require_relative "lib/compose/version"

Gem::Specification.new do |spec|
  spec.name = "compose"
  spec.version = Compose::VERSION
  spec.authors = ["Gregory Schofield"]
  spec.email = ["greg.c.schofield@gmail.com"]

  spec.summary = "Write a short summary, because RubyGems requires one."
  spec.description = "Write a longer description or delete this line."
  spec.homepage = "https://github.com/gscho/habitat-compose"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "dagwood", "~> 1.0"
  spec.add_dependency "file-tail", "~> 1.2"
  spec.add_dependency "minitest", "~> 5.0"
  spec.add_dependency "paint", "~> 2.2"
  spec.add_dependency "posix-spawn", "~> 0.3.15"
  spec.add_dependency "rake", "~> 13.0"
  spec.add_dependency "rubocop", "~> 1.21"
  spec.add_dependency "thor", "~> 1.2"
  spec.add_dependency "tomlrb", "~> 2.0"
  spec.metadata["rubygems_mfa_required"] = "true"
end
