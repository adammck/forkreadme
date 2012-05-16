#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "test/test_*.rb"
end

def fixture name
  File.join File.dirname(__FILE__), "test", "fixtures", name
end

desc "Fetch the test fixtures"
task :fixtures do
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
    %x[git clone git://github.com/forkreadme-test-user-1/test.git #{github_repo}]
  end

  github_fork = fixture "github_fork"
  unless File.exists? github_fork
    %x[git clone git://github.com/forkreadme-test-user-2/test.git #{github_fork}]
  end
end
