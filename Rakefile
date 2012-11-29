#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rspec/core/rake_task'

namespace :spec do
  desc 'run both unit and acceptance tests'
  RSpec::Core::RakeTask.new(:all) do |t|
  end
end

task :default => ["spec:all"]
