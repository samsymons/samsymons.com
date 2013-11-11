---
title: RedditKit 1.0
date: 2013-11-11 12:00 UTC
---

reddit has always had a massive nerd audience. [/r/programming](http://reddit.com/r/programming) has a subscriber base of nearly half a million, and there are countless other subreddits dedicated to the art of software development.

Despite the interest from developers, there has never been a lot of activity around reddit's API ([for those who don't know Python, at least](https://github.com/praw-dev/praw)), especially not compared to the likes of Twitter and Facebook.

I'm thrilled to be able to finally show off [RedditKit](http://redditkit.com), a pair of libraries for communicating with the reddit API, available in Ruby and Objective-C.

## Introducing RedditKit

RedditKit is a project designed to make working with reddit's API as painless as possible. With well-documented and dead simple codebases, RedditKit takes a lot of the hard work out of building software around all that reddit has to offer.

## Goals

* **Documentation**. RedditKit's libraries are completely documented and always up to date.
* **Error handling**. Error messages from reddit’s API are often tricky to work with. RedditKit takes any errors and passes them to you in a consistent and straightforward manner.
* **API coverage**. RedditKit covers as much of the API as possible, giving you access to everything from multireddits to wiki editing.

## The Libraries

### Objective-C

The Objective-C component of RedditKit is built atop [AFNetworking 2](https://github.com/AFNetworking/AFNetworking) and [Mantle](https://github.com/github/Mantle). It is available on iOS 7.0+ and Mac OS X 10.9+.

You can get detailed installation instructions, sample code, and more from its [repository on GitHub](https://github.com/samsymons/RedditKit).

### Ruby

RedditKit.rb uses [Faraday](https://github.com/lostisland/faraday) under the hood, allowing you to add your own middleware to modify requests and reponses as needed. Ruby 1.9.3 and above are supported.

For more, check out the project's [GitHub repository](https://github.com/samsymons/RedditKit.rb).

## Try RedditKit

Let me know what you think about [RedditKit](http://redditkit.com) either [via Twitter](http://twitter.com/sam_symons/) or [email](mailto:sam@samsymons.com).
