#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ForkReadme
  class Error < StandardError
  end

  class NotGitRepo < Error
  end

  class NotGitHubRepo < Error
  end

  class NotGitHubFork < Error
  end
end
