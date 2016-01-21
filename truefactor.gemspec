# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'truefactor/version'

Gem::Specification.new do |spec|
  spec.name          = "truefactor"
  spec.version       = Truefactor::VERSION
  spec.authors       = ["Egor Homakov", "Alexander Yunin"]
  spec.email         = ["homakov@gmail.com"]
  spec.summary       = %q{Truefactor.io can be your only authentication option.}
  spec.description   = %q{Truefactor.io can be your only authentication option or you can add it to existing auth schemes such as devise, authlogic etc.}
  spec.homepage      = "http://truefactor.io"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = `git ls-files -- test/*`.split("\n")
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 4"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
