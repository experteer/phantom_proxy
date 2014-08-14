# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'phantom_proxy2/version'

Gem::Specification.new do |spec|
  spec.name          = "phantom_proxy2"
  spec.version       = PhantomProxy2::VERSION
  spec.authors       = ["Suddani"]
  spec.email         = ["suddani@googlemail.com"]
  spec.summary       = "sdgdfg"
  spec.description   = "dsfsdfg"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "json",        "~> 1.8.1"
  spec.add_dependency "goliath",     "~> 1.0.3"
  spec.add_dependency "journey",     "~> 1.0.4"
  spec.add_dependency "nokogiri",    "~> 1.6.1"
  spec.add_dependency "ruby-hmac",   ">= 0.4.0"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
end
