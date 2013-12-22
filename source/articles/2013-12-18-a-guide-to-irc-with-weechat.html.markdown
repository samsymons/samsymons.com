---
title: IRC With WeeChat
date: 2013-12-18 15:00 UTC
wip: true
---

My relationship with IRC clients on OS X has been a long and fairly unsuccessful one. For whatever reason, I've never been able to find one that really stuck. Those I have tried each have their own issues and quirks that are difficult to get past.

I decided to begin looking for IRC clients at the Terminal level.

## Enter WeeChat

[WeeChat](http://www.weechat.org) is an IRC client written in C. It's simple, configurable, and extensible.

## Installation

WeeChat is best installed with [Homebrew](http://brew.sh/). If that isn't an option, you can find [other installation methods on their website](http://www.weechat.org/download/).

```
brew install weechat
```

## Using WeeChat

To start, open a new WeeChat session with `weechat`. You should see some fancy ASCII art alongside the version number and compilation date. This article was written with WeeChat 0.4.2.

### Joining a Server

Before joining a server, WeeChat requires we define one. We'll use Freenode as an example.

```
/server add freenode chat.freenode.net/6667
```

Quickly verify that Freenode is now in your server list with `/server list`. You can also run `/server listfull` to get detailed information on your servers.

Finally, `/connect freenode` will establish a connection to the server.

### Joining Channels

With a server connection established, you can begin joining channels. It's as straightforward as one would expect: `/join channel_name`. To join #haskell, you would use `/join #haskell` or just `/join haskell`. Easy!

### Buffers and Windows

Before getting into navigation, you need to understand two key concepts: _buffers_ and _windows_. If you have ever used an editor like Vim, this will be very easy to understand.

_Buffers_ can be thought of as an active connection, either to a server or channel. A buffer does not have anything to do with displaying itself on-screen; it is possible to have many open buffers which cannot be seen.

_Windows_ are simply an area on the screen used to display a buffer. Each window displays a single buffer, but many windows can be displayed at once. A buffer can be displayed on many windows at once, or none at all.

Let's quickly test this out. Open WeeChat and join Freenode, if you haven't already.

### Navigation

Once you're connected to a channel, you will see WeeChat's primary UI. This is where you will apply your knowledge of buffers and windows. The interface is made up of a few areas:

* **Title bar**, at the very top of the screen. This displays the current channel's message.
* **Chat area**, where you'll see user and messages.
* **User list**, showing other users in the channel, at the right side of the window.
* **Status bar**, giving you information about the channel, server, and other things.
* **Input bar**, where you enter commands and messages, at the bottom of the window.



## Configuration

Configuration can be done in two ways. You can use WeeChat's `/set` command to set options as the program is running, or you can manually edit the `weechat.conf` file in `~/.weechat/`.

* Join servers automatically: `/set irc.server.your_server_name.autoconnect on`

## Filters

WeeChat comes with sophisticated support for filtering messages, giving you the ability to filter messages based on channel, tag (more on those later), regular expression, or any combination of the three.

You don't need to include tags _and_ a regex; as long as you have one of the two, you're set.

Adding a filter goes like this: `/filter add filter_name channel_name tags regex`

You can do some great things with filters:

* Filter out heretics on #vim: `filter add emacs irc.freenode.#vim * Emacs rocks!`

### Filtering Noisy Messages

My favorite use for filters is stripping out the join/quit messages from other users. WeeChat comes with this ability built in:

```
/set irc.look.smart_filter on
/filter add irc_smart * irc_smart_filter *
```

The first line enables the IRC plugin's smart filter, and the second adds it to the filter list.

Filtering will only hide messages from you. They won't be removed entirely. The implication of this is that disabling your filter will bring back the previously filtered messages immediately.

## Plugins

Nearly everything you do with WeeChat is through a plugin. Even the IRC functionality itself is contained in a plugin – WeeChat without plugins is effectively useless!

## Alternatives

[Irssi](http://www.irssi.org) is another very popular IRC client. Personally, I don't like it as much. It doesn't look as nice out of the box, and the scripting support isn't as good. With that said, it is still a great client in its own right, and is worth a look if WeeChat doesn't appeal.
