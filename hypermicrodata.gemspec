# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hypermicrodata/version'

Gem::Specification.new do |spec|
  spec.name          = "hypermicrodata"
  spec.version       = Hypermicrodata::VERSION
  spec.authors       = ["Jason Ronallo", "Toru KAWAMURA"]
  spec.email         = ["jronallo@gmail.com", "tkawa@4bit.net"]
  spec.description   = %q{HTML5 Microdata extractor with Hypermedia}
  spec.summary       = %q{Ruby library for extracting HTML5 Microdata with Hypermedia}
  spec.homepage      = "https://github.com/tkawa/hypermicrodata"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri"
  spec.add_dependency "mechanize"
  spec.add_dependency "halibut"
  spec.add_dependency "multi_json"
  spec.add_dependency "addressable"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
