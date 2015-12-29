
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hotel/version'

Gem::Specification.new do |spec|
  spec.name          = 'hotel'
  spec.version       = Hotel::VERSION
  spec.authors       = ['David Rivera']
  spec.email         = ['david.r.rivera193@gmail.com']
  spec.summary       = 'JWT for Rails made easy'
  spec.description   = 'it is a hotel'
  spec.homepage      = 'https://github.com/davidrivera/hotel'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split('\x0')
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 2.14'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'rubocop'

  spec.add_dependency 'rails', '>= 3.1.0'
  spec.add_dependency 'jwt', '>= 1.5'
  spec.add_dependency 'redis'
end
