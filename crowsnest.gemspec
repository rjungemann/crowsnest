# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crowsnest/version'

Gem::Specification.new do |spec|
  spec.name          = 'crowsnest'
  spec.version       = Crowsnest::VERSION
  spec.authors       = ['Roger Jungemann']
  spec.email         = ['roger@thefifthcircuit.com']

  spec.summary       = %q(Simple service discovery with multiple backends.)
  spec.homepage      = 'https://github.com/rjungemann/crowsnest'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'zk', '~> 1.9.6'
  spec.add_dependency 'platform-api', '~> 0.8.0'
  spec.add_dependency 'moneta', '~> 0.8.0'
  spec.add_dependency 'pry', '~> 0.10.4'
  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
