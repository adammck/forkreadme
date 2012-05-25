#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "simplecov"
SimpleCov.start

require "vcr"
require "minitest/autorun"

require "forkreadme"
include ForkReadme

VCR.configure do |c|
  c.cassette_library_dir = "test/fixtures/cassettes"
  c.hook_into :faraday
end

def fixture name
  File.join File.dirname(__FILE__), "fixtures", name
end
