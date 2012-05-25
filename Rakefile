#!/usr/bin/env rake
# vim: et ts=2 sw=2

require "fileutils"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "test/test_*.rb"
end

# Check fixtures before running tests.
task :test => "fixtures:check"


namespace :fixtures do
  def fixture name
    File.join File.dirname(__FILE__), "test", "fixtures", name
  end

  desc "Check for test fixtures"
  task :check do
    unless File.exists? fixture "empty"
      puts "Fixtures have not been fetched yet."
      puts "Run $(rake fixtures:fetch) first."
      exit 1
    end
  end

  desc "Fetch test fixtures"
  task :fetch do
    empty = fixture "empty"
    unless File.exists? empty
      %x[mkdir #{empty}]
    end

    git_repo = fixture "git_repo"
    unless File.exists? git_repo
      %x[git init #{git_repo}]
    end

    github_repo = fixture "github_repo"
    unless File.exists? github_repo
      %x[git clone git://github.com/forkreadme-test-user-1/test.git #{github_repo} &>/dev/null]
    end

    github_fork = fixture "github_fork"
    unless File.exists? github_fork
      %x[git clone git://github.com/forkreadme-test-user-2/test.git #{github_fork} &>/dev/null]
    end
  end

  desc "Delete test fixtures"
  task :flush do
    %w[empty git_repo github_repo github_fork].each do |name|
      FileUtils.rm_rf fixture name
    end
  end
end
