require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require 'rake/extensiontask'

Rake::ExtensionTask.new('regexp_property_values') do |ext|
  ext.lib_dir = 'lib/regexp_property_values'
end

if RUBY_PLATFORM !~ /java/i
  # recompile before running specs
  task(:spec).enhance([:compile])
end
