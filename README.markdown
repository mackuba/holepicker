# HolePicker

HolePicker is a Ruby gem for quickly checking all your `Gemfile.lock` files for gem versions with known vulnerabilities.

[![Build Status](https://travis-ci.org/jsuder/holepicker.png?branch=master)](https://travis-ci.org/jsuder/holepicker)

## The story

The beginning of 2013 was a [really bad time](http://www.kalzumeus.com/2013/01/31/what-the-rails-security-issue-means-for-your-startup/) for the Ruby community. In the first few weeks of the year at least 7 serious security issues were found, and Rails had to be updated 4 times so far because of this. It's probably not the end. It's hard to keep track of all the issues and remember which gem versions are OK and which aren't, especially if you have several older and newer Ruby or Rails projects to maintain. So I wrote this tool in order to help with identifying which gems in your projects' gemfiles need to be updated.


## Details

The idea is that there is a [JSON file](https://github.com/jsuder/holepicker/blob/master/lib/holepicker/data/data.json)\* stored in this repository that lists all the recent security-related updates to popular gems: date of the release, URL of the announcement, and a list of affected gems and updated versions. HolePicker provides a command line tool that **downloads the latest data file from GitHub every time**, scans your `Gemfile.lock` files and checks if they contain vulnerable gem versions.

The reason I've done it this way is to make it easier to run the checks against the very latest version of the vulnerability list. It's kind of important to be sure that you haven't missed any last minute updates, and it would be annoying to have to check for new gem versions every time you want to run the tool (and you might not even remember to do that).

If for some reason you don't want to download the JSON file every time, you can use the [`-o` option](#full-option-list). Also, the JSON file specifies the minimum compatible gem version that it can work with, so if new kind of information is added to the file that requires the gem to be updated in order to parse it, the gem will let you know.

Of course the whole system still relies on me manually adding entries to the JSON file and pushing it to GitHub. I'll try to do that quickly, my trusty [@rails_bot](https://github.com/jsuder/rails-retweeter-bot) notifies me pretty quickly when something really bad is happening. If for some reason I don't update the list in time, by all means please send me a pull request.

(\*) YAML obviously wouldn't be appropriate, if you know what I mean.


## Running the tool

To install the tool, just run:

    gem install holepicker

There are two main modes of operation:

### Scanning projects directly

This can be used to scan project directories on your development machine:

    holepicker ~/Projects

You can also scan all apps deployed to a production or demo server; in this case, it's recommended to use the `-c` (`--current`) option in order to skip the old releases in `releases` directories and only scan the `current` directories (I'm assuming you use Capistrano for deployment, because who doesn't?).

    holepicker -c /var/www

HolePicker will return a non-zero status code if vulnerabilities are found, so you could wrap it in some kind of script that's run periodically from cron that notifies you when something is wrong.

### Scanning Nginx/Apache config directory

You might have a lot of random apps deployed in the `/var/www` directory, but only some of them currently enabled in the Nginx config files. In this case, you might want to only check the apps that are actually running. To do that, use the `-f` (`--follow-roots`) option and point HolePicker to your HTTP server's config directory. It will find all the `root` or `DocumentRoot` directives and follow the paths to find the gemfiles of enabled apps.

    holepicker -f /etc/nginx/sites-enabled


## Integration with capistrano

To automatically check for vulnerabilities before deployment, you can add the HolePicker Capistrano recipe:

1. Add `gem 'holepicker'` to your `Gemfile` (preferably with `:require => false`)
2. Add `require 'holepicker/capistrano'` to your `config/deploy.rb`

This will introduce a `cap holepicker` task which will be executed before the deploy.

## Results

This is more or less what you will get if you run HolePicker in a directory with some old Rails projects:

![screenshot](http://f.cl.ly/items/1l3C2c2s0r1k3v033B34/Screen%20Shot%202013-02-16%20at%2001.43.39.png)


## Full option list

`-a`, `--all`

By default, HolePicker will skip directories like `.git`, `tmp`, `cached-copy` etc. when searching for gemfiles. This option turns this feature off.

`-c`, `--current`

Look only for gemfiles that are located directly in a `current` directory.

`-f`, `--follow-roots`

Look for `root`/`DocumentRoot` directives in config files at given locations instead of gemfiles directly.

`-i`, `--ignore gem1,gem2,gem3`

Ignore the gems passed in the parameter.

`-o`, `--offline`

Use an offline copy of the data file - useful if you really need to run the tool, but the network or GitHub is down.


## Similar projects

There are a few other projects with a similar purpose, take a look if HolePicker isn't exactly what you need:

* [bundler-audit](https://github.com/postmodern/bundler-audit) - scans the current project when the app is loaded
* [bundler-organization_audit](https://github.com/grosser/bundler-organization_audit) - scans all your projects on GitHub
* [ruby-advisory-db](https://github.com/rubysec/ruby-advisory-db) - a shared database of vulnerabilities - I'll try to integrate holepicker with it later
* [gemcanary](https://gemcanary.com/) - some kind of web service, not released yet (as of 23.02)
* [gems-status](https://github.com/jordimassaguerpla/gems-status) - a more general tool for checking everything that might be wrong with your gems (work in progress)

## Credits & contributing

Created by [Jakub Suder](http://psionides.eu), licensed under MIT License.

Any feedback and help is welcome, if you have an idea how to improve this tool, let me know or send me an issue or a pull request.

And BTW, big thanks to all the smart people that find and fix all these issues - I hope you won't find much more, but please keep looking.
