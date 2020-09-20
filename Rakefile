require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'
require 'rake/clean'

CLEAN.include 'fixtures/**/Gemfile.lock'
CLEAN.include 'fixtures/**/public/assets'
CLOBBER.include 'pkg'

desc 'Default: run tests.'
task default: :test

namespace :test do
  Rake::TestTask.new(:unit) do |t|
    t.libs += %w(lib test)
    t.pattern = 'test/unit/**/*_test.rb'
    t.verbose = true
  end

  Rake::TestTask.new(:integration) do |t|
    t.libs += %w(lib test)
    t.pattern = 'test/integration/**/*_test.rb'
    t.verbose = true
  end
end

task test: ['test:unit', 'test:integration']
