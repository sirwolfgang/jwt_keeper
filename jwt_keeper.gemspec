# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jwt_keeper/version'

Gem::Specification.new do |spec|
  spec.name          = 'jwt_keeper'
  spec.version       = JWTKeeper::VERSION
  spec.authors       = ['David Rivera', 'Zane Wolfgang Pickett']
  spec.email         = ['david.r.rivera193@gmail.com', 'sirwolfgang@users.noreply.github.com']
  spec.summary       = 'JWT for Rails made easy'
  spec.description   = 'A managing interface layer for handling the creation and validation of JWTs'
  spec.homepage      = 'https://github.com/sirwolfgang/jwt_keeper'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(/^example\//) }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'pry'

  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'fuubar'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'redis-client'
  spec.add_development_dependency 'redis'

  spec.add_dependency 'rails'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'jwt', '~> 3.0'
end
