#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require File.expand_path("../lib/forkreadme/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "forkreadme"
  gem.version       = ForkReadme::VERSION

  gem.authors       = ["Adam Mckaig"]
  gem.email         = ["adam.mckaig@gmail.com"]
  gem.summary       = %q{Generate useful READMEs for GitHub forks}
  gem.homepage      = "https://github.com/adammck/forkreadme"

  gem.add_dependency "trollop", "~> 1.16.2"
  gem.add_dependency "octokit", "~> 1.0.2"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
