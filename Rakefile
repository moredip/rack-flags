#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rspec/core/rake_task'

desc 'run an example app (which lives in the example subdir)'
task :example_app do
  sh "rackup #{File.expand_path("../example/config.ru",__FILE__)}"
end

namespace :spec do
  desc 'run both unit and acceptance tests'
  RSpec::Core::RakeTask.new(:all) do |t|
  end
end

task :default => ["spec:all"]
