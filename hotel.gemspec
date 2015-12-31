# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'keeper/version'

Gem::Specification.new do |spec|
  spec.name          = 'keeper'
  spec.version       = Keeper::VERSION
  spec.authors       = ['David Rivera']
  spec.email         = ['david.r.rivera193@gmail.com']
  spec.summary       = 'JWT for Rails made easy'
  spec.description   = 'it is a keeper'
  spec.homepage      = 'https://github.com/davidrivera/keeper'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'dotenv'

  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'fuubar'
  spec.add_development_dependency 'simplecov'

  spec.add_dependency 'redis'
  spec.add_dependency 'rails', '>= 4.2'
  spec.add_dependency 'jwt', '>= 1.5'
end
