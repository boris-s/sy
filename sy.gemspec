# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sy/version'

Gem::Specification.new do |spec|
  spec.name          = "sy"
  spec.version       = SY::VERSION
  spec.authors       = ["Boris Stitnicky"]
  spec.email         = ["borisstitnicky@centrum.cz"]
  spec.summary       = %q{Simple and concise way to express physical units.}
  spec.description   = %q{Physical units library}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "y_support"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
