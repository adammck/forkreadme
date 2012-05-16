#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "uri"
require "octokit"

module ForkReadme
  class Generator
    include URI::REGEXP::PATTERN

    def initialize path, with_images
      @path = path
      @with_images = with_images

      repo_name = github_repo_name @path
      @repo = octokit.repo repo_name
      @parent = parent_of @repo
    end

    def readme
      intro + "\n\n" + (links.join "\n")
    end

    # Public: Returns the introduction paragraph.
    def intro
      link = link_to(@parent.name, @parent.html_url)
      "This is a fork of #{link}, with pull requests:"
    end

    # Public: Returns a paragraph summarizing the pull requests.
    def links
      pull_requests(@parent).select do |pull|
        pull.head.repo.id == @repo.id

      end.map do |pull|
        "* " + line_for(pull, @with_images)
      end
    end

    private

    # Private: Returns a line of Markdown summarizing a pull request.
    def line_for pull_request, with_images
      img = if with_images
        image "Status of ##{pull_request.number}", status_image(pull_request)
      end

      suffix = img ? (" " + img) : ""
      link_to(pull_request.title, pull_request.html_url) + suffix
    end

    # Private: Returns the parent repo (as an Octokit repo) of an Octokit repo,
    # or raises NotFork if the repo does not have a parent.
    def parent_of child_repo
      if child_repo.parent
        parent_repo_name = full_name child_repo.parent
        octokit.repo parent_repo_name
      else
        child_name = full_name child_repo
        raise NotFork.new "Not a GitHub fork: #{child_name}"
      end
    end

    # Private: Returns a link in Markdown format.
    def link_to text, href
      "[#{text}] (#{href})"
    end

    # Private: Returns an image in Markdown format.
    def image alt_text, href
      "!" + link_to(alt_text, href)
    end

    # Private: Returns an Array containing the logins of all collaborators for
    # an Octokit repo.
    def collaborator_logins repo
      octokit.collabs(full_name repo).map do |user|
        user.login
      end
    end

    # Private: Returns the URL of the status image (via pullstat.us) for an
    # Octokit pull request.
    def status_image pull_request
      pull_request.html_url.sub "github.com", "pullstat.us"
    end

    # Private: Returns all pull request summaries (as returned by the "List pull
    # requests" API, and wrapped by Octokit) for an Octokit repo.
    def pull_requests repo
      name = full_name repo
  
      %w[open closed].reduce([]) do |memo, state|
        memo | octokit.pulls(name, state, :per_page=>100)
      end
    end
  
    # Private: Returns the full GitHub repo name (e.g. adammck/forkreadme) of a
    # Git working directory, or raises NotGitHubRepo.
    def github_repo_name path
      clone_url = parse_url remote_url path

      if clone_url.host.downcase != "github.com"
        raise NotGitHubRepo.new "Not a GitHub repo: #{path}"
      end

      chop_extension chop_leading_slash clone_url.path
    end
  
    # Private: Returns the full GitHub repo name of an Octokit repo.
    def full_name repo
      "#{repo.owner.login}/#{repo.name}"
    end
  
    # Private: Returns a configured Octokit client.
    def octokit
      @ok ||= Octokit.new(:auto_traversal=>true)
    end
  
    # Private: Returns the remote clone URL of a Git working directory, or
    # raises NotGitRepo.
    def remote_url path
      unless is_working_dir path
        raise NotGitRepo.new "Not a Git repo: #{path}"
      end

      %x{git config --file #{path}/.git/config --get remote.origin.url}
    end
  
    # Private: Returns a parsed URL. Wraps `URI.parse` with support for Git's
    # SCP-like syntax (look like: git@github.com:adammck/whatever.git).
    def parse_url url
      begin
        URI.parse(url)
  
      rescue URI::InvalidURIError
        if m = url.match("^(#{USERINFO})@(#{HOST}):(#{REL_PATH})$")
          URI::Generic.new "ssh", m[1], m[2], 22, nil, "/" + m[3], nil, nil, nil
  
        else
          raise
        end
      end
    end

    # Private: Return true if +path+ is a Git working directory.
    def is_working_dir path
      File.exist? File.expand_path ".git", path
    end

    # Private: Returns a filename with the extension removed.
    def chop_extension filename
      filename.sub /\.\w+$/, ""
    end

    # Private: Returns a filename with the leading slash removed.
    def chop_leading_slash filename
      filename.sub /^\//, ""
    end
  end
end
