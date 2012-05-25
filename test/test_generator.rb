#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require File.expand_path(File.dirname(__FILE__) + "/test_helper.rb")

describe Generator do
  describe "Errors" do
    it "rejects paths which are not git repos" do
      assert_raises(NotGitRepo) do
        Generator.new fixture("empty")
      end
    end

    it "rejects repos which are not hosted on github" do
      assert_raises(NotGitHubRepo) do
        Generator.new fixture("git_repo")
      end
    end

    it "rejects github repos which are not forks" do
      VCR.use_cassette("github_repo") do
        assert_raises(NotGitHubFork) do
          Generator.new fixture("github_repo")
        end
      end
    end
  end

  describe "README" do
    it "generates a readme without images" do
      VCR.use_cassette("github_fork") do
        g = Generator.new fixture("github_fork")
        assert_equal File.read(fixture("README_without_images.md")), g.readme
      end
    end

    it "generates a readme with images" do
      VCR.use_cassette("github_fork") do
        g = Generator.new fixture("github_fork")
        assert_equal File.read(fixture("README_with_images.md")), g.readme(true)
      end
    end
  end
end
