#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "uri"
require "octokit"

module ForkReadme
  class Generator
    include URI::REGEXP::PATTERN

    def initialize path
      @path = path

      repo_name = github_repo_name @path
      @repo = octokit.repo repo_name
      @parent = parent_of @repo
    end

    def readme with_images=false
      intro + "\n\n" + (links(with_images).join "\n")
    end

    # Public: Returns the introduction paragraph.
    def intro
      link = link_to(@parent.name, @parent.html_url)
      "This is a fork of #{link}, with pull requests:"
    end

    # Public: Generate a paragraph summarizing the pull requests.
    #
    # with_images - Include pullstat.us images?
    #
    # Returns the paragraph as Markdown.
    def links with_images
      pull_requests(@parent).select do |pull|
        @repo.id == (pull.head.repo && pull.head.repo.id)

      end.map do |pull|
        "* " + line_for(pull, with_images)
      end
    end

    private

    # Private: Generate a one-line summary of a pull request.
    #
    # pull_request - The Octokit pull request to be summarized.
    # with_image   - Include a pullstat.us image?
    #
    # Returns the line as Markdown.
    def line_for pull_request, with_image
      img = if with_image
        image "Status of ##{pull_request.number}", status_image(pull_request)
      end

      suffix = img ? (" " + img) : ""
      link_to(pull_request.title, pull_request.html_url) + suffix
    end

    # Private: Returns the parent repo (as an Octokit repo) of an Octokit repo,
    # or raises NotGitHubFork if the repo does not have a parent.
    def parent_of child_repo
      if child_repo.parent
        parent_repo_name = full_name child_repo.parent
        octokit.repo parent_repo_name
      else
        child_name = full_name child_repo
        raise NotGitHubFork.new "Not a GitHub fork: #{child_name}"
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
      origin = remote_origin_url path

      if origin == ""
        raise NotGitHubRepo.new "No remote origin URL: #{path}"
      end

      clone_url = parse_url origin

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
  
    # Private: Returns the remote origin URL of a Git working directory (which
    # may be an empty string, if the repo has no origin) or raises NotGitRepo.
    def remote_origin_url path
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
      filename.sub %r{\.\w+$}, ""
    end

    # Private: Returns a filename with the leading slash removed.
    def chop_leading_slash filename
      filename.sub %r{^/}, ""
    end
  end
end
