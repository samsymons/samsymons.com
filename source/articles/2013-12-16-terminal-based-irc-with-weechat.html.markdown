---
title: Using IRC With WeeChat
date: 2013-12-16 15:00 UTC
tags:
---

My relationship with IRC clients on OS X has been a long and fairly unsuccessful one. For whatever reason, I've never been able to find one that really stuck. Those I have tried each have their own issues and quirks that are difficult to get past.

I decided to begin looking for IRC clients at the Terminal level.

## Enter WeeChat

[WeeChat](http://www.weechat.org) is an IRC client written in C. It's simple, configurable, and supports everything you'd want in an IRC client.

## Getting Started

WeeChat is best installed via Homebrew. If that isn't an option, you can find [other installation methods on their website](http://www.weechat.org/download/).

```
brew install weechat
```

## Usage

To start, open a new WeeChat session with `weechat`. You should see some fancy ASCII art alongside the version number and compilation date. This article was written with WeeChat 0.4.2, but you should be fine with something slightly different.

### Joining a Server

Before joining a server, we'll need to add one, using Freenode as an example.

`/server add freenode chat.freenode.net/6667`

Quickly verify that Freenode is now in your server list.

`/server list`

You can also run `/server listfull` to get much more detailed output.

Finally, `/connect freenode` will join your new channel.

### Joining Channels

With a server connection established, you can begin joining channels. It's as straightforward as one would expect: `/join channel_name`. To join #haskell, you would use `/join #haskell`. Easy!

## Configuration

### Filters

WeeChat comes with sophisticated support for filtering messages, giving you the ability to filter messages based on channel, tag (more on those later), regular expression, or any combination of the three.

Adding a filter goes like this: `/filter add filter_name channel_name tags regex`

You can do some great things with filters:

* Filter out heretics on #vim: `filter add emacs irc.freenode.#vim * Emacs rocks!`

#### Filtering Noisy Messages

```
/set irc.look.smart_filter on
/filter add irc_smart * irc_smart_filter *
```

The first line enables the IRC plugin's smart filter, and the second adds it to the filter list.

Filtering will only hide messages from you, rather than removing them entirely. This gives you the ability to disable your filter and see the previously filtered messages immediately.

## Plugins

Almost everything you do with WeeChat is via a plugin. Even the IRC functionality itself is contained in a plugin; WeeChat without plugins is effectively useless!

## Alternatives

[Irssi](http://www.irssi.org) is another very popular IRC client. Personally, I don't like it as much. It doesn't look as nice out of the box, and the scripting support is more limited. With that said, it is still a great client in its own right, and is worth a look if WeeChat doesn't appeal.
