This is a command-line utility for generating READMEs for GitHub forks.

I have quite a few forks of popular repos which contain no useful indication of
why they exist. Mostly they're hanging around waiting for a pull request to be
merged into or rejected from the upstream repo. And since my changes are tucked
away in feature branches, it's not immediately obvious to visitors (or me) why I
created the fork, what I changed, and whether those changes have been merged
upstream.

My solution is to replace the `README.md` in the master branch of my fork with a
note detailing what and why.  
This tool does that automatically.


## Usage

```bash
$ gem install forkreadme
$ forkreadme generate
```

Here's an [example of the output] [example].


## License

[Fork README] [repo] is available under the [MIT license] [license].




[repo]:    https://github.com/adammck/forkreadme
[license]: https://raw.github.com/adammck/forkreadme/master/LICENSE
[example]: https://github.com/adammck/grit
