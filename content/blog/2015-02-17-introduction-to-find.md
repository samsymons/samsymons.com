---
title: Introduction to find
date: "2015-02-17"
tags: [ "unix", "tutorial" ]
slug: "introduction-to-find"
---

Of the various Unix utilities I use semi-regularly, `find` is the one that has me reaching for its documentation the most often. Every time I do, it's a reminder of how powerful it can be, if you can just remember how to use it.

This article goes over how to use `find` beyond just searching for files by name, mostly just so that I have something to refer back to when I inevitably forget how to use it again.

### The Basics

Generally, `find` usage looks like this: `find path arguments`. `find` takes a path (searched recursively by default), and a set of arguments.

The `-name` argument is used to find files by name. For files named `myawesomefile` in your current directory (including subdirectories), you would run `find . -name myawesomefile`.

When looking for a file by name, you can use wildcard characters to help broaden your search. For all Markdown files found in and below your current directory, you could run `find . -name *.markdown`

### Finding Files By Date

`find` has support for finding files by last access date, file modification date, and file contents modification date.

To find all files that were edited less than a day ago: `find . -mtime -1`. Each of the time arguments (`-mtime`, in this case) work 24 hours at a time. You can specify this by adding a qualifier to the end of your time argument; `find . -mtime +60s` will return all files modified over a minute ago.

### Finding Files By Permissions

Say you want to find all executable files under a directory. This is the incantation for you: `find . -type f -perm +111`

The `-perm` argument can be preceded by either a `+` or a `-`. The man page for `find` has this to say:

>   If the mode is preceded by a plus ("+"), this primary evaluates to true if any of the bits in the mode are set in the file's mode bits.

### Finding Files By Size

Perhaps my favorite of `find`'s abilities: the `size` argument.

For fun, let's learn which files are hogging Dropbox: `find ~/Dropbox -size +100M`. What about files which are smaller than 10KB on our desktop? `find ~/Desktop -size -10k`.

Note the difference in the trailing character on those last commands; uppercase `M` specifies megabytes, whereas lowercase `k` indicates kilobytes. `find`'s size support goes from bytes all the way up to petabytes.

### Finding Files By Type

Last of all, `find` knows the difference between files and directories. For all directories greater than 1GB under the `~/Library` directory (this may take a few seconds): `find ~/Library -size +1G -type d`

`-type f` lets you specify files exclusively, with `l` and `s` giving you the ability to find links and sockets respectively.

### Combining Arguments

`find` allows you to not only specify which arguments you want to look for, but also those you _do not_ want to look for.

Going back to the Markdown hunting earlier, try finding all files which _aren't_ Markdown: `find . ! -name *.markdown`. By adding `!` in front of an expression, `find` negates it for you.

How about finding all Sass and CSS files in a project? `find . -name *.css -o -name *.scss` uses the `-o` ("or") operator to find files across multiple name formats.
