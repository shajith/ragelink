require "bundler/gem_tasks"

require 'rake/extensiontask'

Rake::ExtensionTask.new('ragelink')

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end
