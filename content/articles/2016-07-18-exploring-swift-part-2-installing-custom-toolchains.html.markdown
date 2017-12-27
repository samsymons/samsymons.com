---
title: "Exploring Swift, Part 2: Installing Custom Toolchains"
date: 2016-07-18 15:36 UTC
tags: swift
---

As you’re making changes to Swift, you’ll want to test them out by using your new version of the compiler and writing some programs with it. The most convention way to do this is to provide the system with a _new_ version of Swift to use.

Some of the projects in the Swift ecosystem (like the package manager) may even _require_ that you have a more recent version than that which Xcode provides. As Swift 3.0 evolves, the other projects evolve with it, and these changes can happen faster than Xcode betas are released.

### What Are Toolchains Anyway?

In recent versions of Xcode, you may have seen mentions of _toolchains_. You might have even seen people talking about the `TOOLCHAINS` environment variable. It’s important to know what this is all about, since toolchains are the best way to use your own homegrown version of Swift.

A toolchain is little more than a collection of binaries. It contains the Swift compiler, LLDB, along with a few other tools and an `Info.plist` with some information about itself. It’s a way of containing everything you need to build a Swift project in a single directory.

The way Xcode manages these is by putting them all into `Library/Developer/Toolchains` and then pointing the `swift-latest.xctoolchain` symlink (in the same directory) at whichever one is currently active. It also uses this list to populate the Toolchains screen in Xcode’s preferences.

### Building Swift

As a toolchain is just a directory with some Swift binaries in it, building a toolchain of your very own isn't too scary. To kick things off, `cd` into your Swift directory and bring the project up to date:

```bash
./utils/update-build --clone-with-ssh
```

> Before building, make sure you `xcode-select` to your Xcode-beta.app path. The build process looks for the 10.12 SDK, which is bundled with Xcode 8. Without this, you won't be able to build!

You should be set to build Swift now.

```bash
./utils/build-script -R --llbuild --swiftpm
```

Creating a toolchain is pretty straightforward. I found a great [mailing list thread](https://lists.swift.org/pipermail/swift-build-dev/Week-of-Mon-20160530/000492.html) linking to this [build script from Daniel Dunbar](https://gist.github.com/ddunbar/598bf66952fba0e9d8aecc54995f018e). As Daniel mentioned, this script was written for his personal use; I [created a modified version which can be easily updated for any system](https://gist.github.com/samsymons/a026756ff7afc3154d4649bc955d08ab).

This script can be run after compilation to build a `swift-dev.toolchain` directory.

### Using Custom Toolchains

With your custom `swift-dev` toolchain in hand (it will be in the same build directory as Swift, `Ninja-Release`), head over to `Libary/Developer/Toolchains` and drop it in there. Now you can tell `xcrun` which version of Swift to use.

```bash
export TOOLCHAINS=swift-dev
```

After setting the `TOOLCHAINS` environment variable, the system will look in `Libary/Developer/Toolchains` for a corresponding version of Swift instead of using the toolchains that come packaged with Xcode. Now you're ready to use your new compiler!

```bash
› swift --version
Swift version 3.0-dev (LLVM 505155ac3d, Clang f8606ef4b8, Swift b4cba58330)
Target: x86_64-apple-macosx10.9
```

Perfect! The `swift` binary prints the SHA for each dependency its using, so this should line up with the latest commit you built from.