#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ForkReadme
  class Error < StandardError
  end
  
  class NotRepo < Error
  end
  
  class NotFork < Error
  end
end
