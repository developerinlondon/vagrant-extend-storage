# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-extended-storage/version'

Gem::Specification.new do |gem|
  gem.name          = "vagrant-extended-storage"
  gem.version       = VagrantPlugins::ExtendedStorage::VERSION
  gem.authors       = ["Nayeem Syed"]
  gem.email         = ["developerinlondon@gmail.com"]
  gem.description   = "A Vagrant plugin that extends the root storage by attaching a new volume and adding it to lvm"
  gem.summary       = "Vagrant Extended Storage Plugin"
  gem.homepage      = "https://github.com/developerinlondon/vagrant-extended-storage"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
end
