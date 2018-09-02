lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'regexp_property_values/version'

Gem::Specification.new do |s|
  s.name          = 'regexp_property_values'
  s.version       = RegexpPropertyValues::VERSION
  s.authors       = ['Janosch Müller']
  s.email         = ['janosch84@gmail.com']

  s.summary       = "Inspect property values supported by Ruby's regex engine"
  s.description   = 'This small library lets you see which property values '\
                    'are supported by the regular expression engine of the '\
                    'Ruby version you are running, and what they match.'
  s.homepage      = 'https://github.com/janosch-x/regexp_property_values'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.require_paths = ['lib']

  s.extensions = %w[ext/regexp_property_values/extconf.rb]

  s.required_ruby_version = '>= 2.0.0'

  s.add_development_dependency 'bundler', '~> 1.16'
  s.add_development_dependency 'character_set', '~> 1.0.0'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rake-compiler', '~> 1.0'
  s.add_development_dependency 'rspec', '~> 3.0'
end
