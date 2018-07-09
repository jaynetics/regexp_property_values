require 'bundler/gem_tasks'
require 'rubygems/package_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require 'rake/extensiontask'

Rake::ExtensionTask.new('regexp_property_values') do |ext|
  ext.lib_dir = 'lib/regexp_property_values'
end

namespace :java do
  java_gemspec = eval File.read('./regexp_property_values.gemspec')
  java_gemspec.platform = 'java'
  java_gemspec.extensions = []

  Gem::PackageTask.new(java_gemspec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
    pkg.package_dir = 'pkg'
  end
end

task package: 'java:gem'

if RUBY_PLATFORM !~ /java/i
  # recompile before running specs
  task(:spec).enhance([:compile])
end
