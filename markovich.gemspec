# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'markovich/version'

Gem::Specification.new do |spec|
  spec.name          = "markovich"
  spec.version       = Markovich::VERSION
  spec.authors       = ["Shuhei Takahashi"]
  spec.email         = ["shuhei-takahashi@und-meer.com"]
  spec.description   = %q{Markov Bot}
  spec.summary       = %q{Markov Bot}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mongo", ">= 1.6.4"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
