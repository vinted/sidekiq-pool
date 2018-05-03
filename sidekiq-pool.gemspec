# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq/pool/version'

Gem::Specification.new do |spec|
  spec.name          = 'sidekiq-pool'
  spec.version       = Sidekiq::Pool::VERSION
  spec.authors       = ['Laurynas Butkus', 'Raimondas Valickas']
  spec.email         = ['laurynas.butkus@gmail.com', 'raimondas.valickas@gmail.com']

  spec.summary       = %q{Forks and manages multiple Sidekiq processes}
  spec.description   = %q{Allows Sidekiq using more CPU cores on Ruby MRI by forking multiple processes.}
  spec.homepage      = 'https://github.com/laurynas/sidekiq-pool'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = ['sidekiq-pool']
  spec.require_paths = ['lib']

  spec.add_dependency 'sidekiq', '>= 4.0', '< 6.0'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
