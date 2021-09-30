# ForkReadme

This is a command-line utility for generating useful READMEs for GitHub forks.

I have quite a few forks which contain no useful indication of why they exist.
Mostly they're hanging around waiting for a pull request to be merged into or
rejected from the upstream repo. And since my changes are tucked away in feature
branches, it's not immediately obvious to visitors (including myself, six months
later) why I created the fork, what I changed, and whether or not those changes
have been merged upstream.

My solution is to create an orphan branch containing a README explaining what's
going on, and make that the default branch on GitHub. This little tool does the
first part automatically.


## Installation

Get it via [RubyGems] [gem]:

```
$ gem install forkreadme
```


## Usage

1. Create an empty branch with no history:

   ```
   $ git checkout --orphan forkreadme
   $ git reset --hard
   ```

   Check out `git help checkout` and search for `--orphan` for more info.

2. Generate the README:

   ```
   $ forkreadme > README.md
   ```

   Here's [an example] [example] of the output.

3. Push it to GitHub:

   ```
   $ git add README.md
   $ git commit -m "Add README.md"
   $ git push origin forkreadme
   ```

4. [Change the default branch] [set-branch] on GitHub.


## License

ForkReadme is available under the [MIT license] [license].




[gem]:        https://rubygems.org/gems/forkreadme
[example]:    https://github.com/adammck/grit#readme
[set-branch]: https://github.com/blog/421-pick-your-default-branch
[license]:    https://raw.github.com/adammck/forkreadme/master/LICENSE
