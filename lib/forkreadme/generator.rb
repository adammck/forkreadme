#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "uri"
require "octokit"

module ForkReadme
  class Generator
    include URI::REGEXP::PATTERN

    def initialize dir
      @dir = dir
    end

    def readme
      repo_name = github_repo_name @dir

      if repo_name.empty?
        raise NotRepo.new "Not a GitHub repo: #{@dir}"
      end

      repo = octokit.repo repo_name

      unless repo.fork
        raise NotFork.new "Not a GitHub fork: #{repo_name}"
      end

      parent_name = full_name repo.parent
      parent = octokit.repo parent_name

      s = []
      s << "This is a fork of [#{parent.name}] (#{parent.html_url}), with pull requests:"
      s << ""

      logins = collaborator_logins repo
      my_pulls = pull_requests(parent).select do |pull|
        pull.user and logins.include?(pull.user.login)
      end

      my_pulls.each do |short_pull|
        pull = pull_request(parent, short_pull.number)
        if repo_name == full_name(pull.head.repo)
          s << " * [#{pull.title}] (#{pull.html_url})"
        end
      end

      s.join "\n"
    end
  
  
    private
  
    # Private: Returns an Array containing the logins of all collaborators for an
    # Octokit repo.
    def collaborator_logins repo
      octokit.collabs(full_name repo).map do |user|
        user.login
      end
    end
  
    # Private: Returns all pull request summaries (as returned by the "List pull
    # requests" API, and wrapped by Octokit) for an Octokit repo.
    def pull_requests repo
      name = full_name repo
  
      %w[open closed].reduce([]) do |memo, state|
        memo | octokit.pulls(name, state, :per_page=>100)
      end
    end
  
    # Private: Return full pull request (as returned by the "Get a single pull
    # request" API, and wrapped by Octokit) to an Octokit repo and pull number.
    def pull_request repo, number
      octokit.pull full_name(repo), number
    end
  
    # Private: Returns the full GitHub repo name of a Git working directory.
    def github_repo_name path
      clone_url = parse_url remote_url path
      chop_extension clone_url.path
    end
  
    # Private: Returns the full GitHub repo name of an Octokit repo.
    def full_name repo
      "#{repo.owner.login}/#{repo.name}"
    end
  
    # Private: Returns a configured Octokit client.
    def octokit
      @ok ||= Octokit.new(:auto_traversal=>true)
    end
  
    # Private: Returns the remote url of a Git working directory.
    def remote_url path
      %x{git config --file #{path}/.git/config --get remote.origin.url}
    end
  
    # Private: Returns a parsed URL. Wraps `URI.parse` with support for Git's
    # SCP-like syntax (look like: git@github.com:adammck/whatever.git).
    def parse_url url
      begin
        URI.parse(url)
  
      rescue URI::InvalidURIError
        if m = url.match("^(#{USERINFO})@(#{HOST}):(#{REL_PATH})$")
          URI::Generic.new "ssh", m[1], m[2], 22, nil, m[3], nil, nil, nil
  
        else
          raise
        end
      end
    end
  
    # Private: Returns a filename with the extension removed.
    def chop_extension filename
      filename.sub /\.\w+$/, ""
    end
  end
end
