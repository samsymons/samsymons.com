---
title: Fast Navigation using z
date: 2014-01-03 12:00 UTC
---

Working in the shell can be incredibly empowering. Thanks to the [philosophy of Unix](http://en.wikipedia.org/wiki/Unix_philosophy), you can get all sorts of things done with incredible speed... except navigation. For this, z is the answer.

z is a script which keeps track of the directories you have visited and lets you go back to them very quickly. If you've ever used [autojump](https://github.com/joelthelion/autojump) or [fasd](https://github.com/clvv/fasd), you'll know what z is about.

It's fantastic for those frequently jumping around the filesystem. All you need to know is a part of the directory name you want to jump to. For example, if you have a project found at `~/Projects/Rails/SomeRailsApp`, running `z somerails` will jump to the project, saving you from having to remember the path each time.

## Setting Up

Because z is just a shell script, you only need to get the `z.sh` file and place it where your shell can find it.

1. Get the file from the [project's repository](https://github.com/rupa/z)
2. Update your shell's startup file (`.bashrc`,`.zshrc`, etc.) to include the location of `z.sh` in your $PATH. If you put `z.sh` in a directory like `~/.scripts/`, then your $PATH will have to include `$HOME/.scripts`
3. Source your shell's startup file with `source ~/.zshrc` (or whatever your startup file's name is)

## In Action

Say you have a directory structure like this:

```
~
├── Projects
|   ├── Rails
|	|	├── Some Project
|   └── iOS
|	|	├── Another Project
```

Changing into the `~/Projects` directory then checking z's history with `z -l` (or just `z` with no arguments) should give you something like this:

```bash
common:    /Users/samsymons/Projects
4          /Users/samsymons/Projects
```

Then after visiting the `Rails` directory:

```bash
common:    /Users/samsymons/Projects
8          /Users/samsymons/Projects
8          /Users/samsymons/Projects/Rails
```

As you can see, z only remembers directories you have visited after its installation. It won't put you in a directory unless you specifically go there first. Note the ranks listed to the left of the output; the higher the rank, the more likely the directory will be chosen.

`cd` back into your home directory, then run `z rails`. z will look at its history, find the first (case insensitive) match for 'rails', and take you straight there. If you have visited multiple different directories named 'rails', z will use their ranks to decide which one to pick.

## How It Works

z's magic comes from its ordering of directories by "[frecency](http://en.wikipedia.org/wiki/Frecency)". The more often a directory is visited, the higher in the list it will appear.

The crucial aspect, however, is that z will favor more recently visited directories — no matter how many times you visited a directory in the past, if you haven't been there in a while, its rank will start to decay.

Directory rankings are stored in `~/.z`. To reset the history, delete that file. z will recreate it when you start visiting new directories.

## Try z

My productivity has gone up sharply since installing z. If you do any sort of navigation in a shell, give it a shot.

