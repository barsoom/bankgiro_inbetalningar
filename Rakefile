#!/usr/bin/env rake
require "bundler/gem_tasks"

# Until updated, here's a compatbility hack
# https://stackoverflow.com/a/35893941/267348
module TempFixForRakeLastComment
  def last_comment
    last_description
  end
end
Rake::Application.send :include, TempFixForRakeLastComment

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

