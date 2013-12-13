[![Build Status](https://travis-ci.org/smashwilson/websinger.png?branch=master)](https://travis-ci.org/smashwilson/websinger)

# Websinger

This is a weekend project of mine from a while ago. As such, the code quality
is not great; test coverage is minimal to none; and I didn't bother to do things
like "write down dependencies so that other people could use it". In other words,
caveat emptor and all that.

I do mean to come back to this and make it nicer in the future, especially if it's
useful for people other than me. In the meantime, pull requests are more than
welcome!

## What is it?

Websinger turns that Linux server where you back up all of your music into a
jukebox.

When I was first thinking about this, I found a number of applications online
that let you play music from the server through your browser. However, my
need was unique in that it was the server that had the speakers: I wanted to
be able to index all of the backed-up media, search it nicely, and allow
everyone in the house to collaboratively edit a single playlist of what would
play over the speakers.

## Installation

Websinger currently runs on my Ubuntu server. It might run on yours, too! I run
with Ruby 1.9.2 provided by a system-wide [rvm](http://beginrescueend.com/rvm/install)
installation. If you don't, the Rakefile in particular will probably not work
for you.

First, install these non-Ruby prerequisities:

```
sudo apt-get install apache2 mpg123 libmagic-dev
```

Clone the Github repository wherever you wish, and resolve the Ruby dependencies
with [Bundler](http://gembundler.com):

```
sudo gem install bundler

mkdir -p /var/rails
cd /var/rails
git clone git://github.com/smashwilson/websinger.git
cd websinger
bundle install
```

Deploy the Rails app however you wish. I use
[Apache and Passenger](http://www.modrails.com/documentation/Users%20guide%20Apache.html#_installing_via_the_gem).

Next, use the included Rake task to create the websinger user and register the
player daemon with upstart:

```
# You probably want to read lib/tasks/install.rake first!
sudo rake install
```

Finally, you'll need to start the player daemon:

```
sudo start websinger-player
```

Now your server is running, but it has no music yet.

## Adding Music

Websinger provides a Rake task for scanning a directory tree to add mp3 files
to its database. I have a script that invokes it as follows:

```
#!/bin/bash

export RAILS_ENV=production
cd /var/rails/websinger
rake websinger:scan[/home/smash/music,true,/home/smash/import-errors.log] --trace
```

This will import all .mp3 files found under `/home/smash/music`, reporting verbose
progress and logging error messages to `import-errors.log`. Currently, things
that give the scan task trouble include blank IDv3 titles and non-UTF-8 characters
within track paths.
