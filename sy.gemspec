# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["boris"]
  gem.email         = ["\"boris@iis.sinica.edu.tw\""]
  gem.description   = %q{Physical units library}
  gem.summary       = %q{The simplest and most concise way of encoding physical units.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sy"
  gem.require_paths = ["lib"]
  gem.version       = Sy::VERSION

  gem.add_dependency "activesupport"
end
