#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "simplecov"
SimpleCov.start

require "minitest/autorun"

require "forkreadme"
include ForkReadme

def fixture name
  File.join File.dirname(__FILE__), "fixtures", name
end
