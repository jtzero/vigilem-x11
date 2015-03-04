# -*- encoding: utf-8 -*-
require './lib/vigilem/x11/version'

Gem::Specification.new do |s|
  s.name          = 'vigilem-x11'
  s.version       = Vigilem::X11::VERSION
  s.platform      = Gem::Platform::RUBY 
  s.summary       = 'X11 bindings for Vigilem'
  s.description   = 'X11 bindings for Vigilem, currently used internally only'
  s.authors       = ['jtzero']
  s.email         = ['jtzero511@gmail']
  s.homepage      = 'http://rubygems.org/gems/vigilem-x11'
  s.license       = 'MIT'
  
  s.add_dependency 'xlib'
  
  s.add_dependency 'vigilem-core'
  
  s.add_development_dependency 'yard'
  s.add_development_dependency 'bundler', '~> 1.7'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'rspec-given'
  s.add_development_dependency 'turnip'
  s.add_development_dependency 'guard-rspec'
  
  s.files         = Dir['{lib,spec,ext,test,features,bin}/**/**']
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']
end
