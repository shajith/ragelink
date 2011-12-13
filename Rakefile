require "bundler/gem_tasks"

require 'rake/extensiontask'

Rake::ExtensionTask.new('ragelink') do |task|
  task.ext_dir = "lib/ragelink/ext"
  task.lib_dir = "lib/ragelink/ext"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test
