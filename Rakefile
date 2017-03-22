require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rake/extensiontask'

task build: :compile

Rake::ExtensionTask.new('sample_ruby_extension_in_crystal') do |ext|
  ext.lib_dir = 'lib/sample_ruby_extension_in_crystal'
end

task default: [:clobber, :compile, :spec]
