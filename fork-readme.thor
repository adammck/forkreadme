#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "uri"
require "octokit"

class Test < Thor
  include URI::REGEXP::PATTERN
  SCP_LIKE_URL = "^(#{USERINFO})@(#{HOST}):(#{REL_PATH})$"

  desc "readme", "generate a README"
  def readme
    octokit = Octokit.new(:auto_traversal=>true)

    clone_url = parse_url remote_url Dir.pwd
    repo_name = chop_extension clone_url.path
    repo = octokit.repo repo_name
    
    unless repo.fork
      say "Not a fork: #{repo_name}"
      return
    end

    puts "This is a fork of [#{repo.parent.name.capitalize}] (#{repo.parent.html_url}), with pull requests:"
    puts

    parent_repo_name = "#{repo.parent.owner.login}/#{repo.parent.name}"
    
    pulls = %w[open closed].reduce([]) do |memo, state|
      memo | octokit.pulls(parent_repo_name, state, :per_page=>100)
    end
    
    my_pulls = pulls.map do |short_pull|
      long_pull = octokit.pull parent_repo_name, short_pull.number
      if long_pull.head and long_pull.head.repo
        this_repo_name = "#{long_pull.head.repo.owner.login}/#{long_pull.head.repo.name}"
        long_pull if this_repo_name == repo_name
      end
    end

    my_pulls.compact.each do |pull|
      puts " * [#{pull.title}] (#{pull.html_url})"
    end
  end

  private

  def remote_url path
    %x{git config --file #{path}/.git/config --get remote.origin.url}
  end

  def parse_url url
    begin
      URI.parse(url)
  
    rescue URI::InvalidURIError
      if m = url.match(SCP_LIKE_URL)
        URI::Generic.new "ssh", m[1], m[2], 22, nil, m[3], nil, nil, nil
  
      else
        raise
      end
    end
  end

  def chop_extension path
    path.sub /\.\w+$/, ""
  end
end
