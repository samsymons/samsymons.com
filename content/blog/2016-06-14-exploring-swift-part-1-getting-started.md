---
title: "Exploring Swift, Part 1: Getting Started"
date: "2016-06-14"
tags: [ "swift" ]
slug: "exploring-swift-part-1-getting-started"
---

With the [open source release of Swift in December last year](https://developer.apple.com/swift/blog/?id=34), developers everywhere have been able to delve into the code behind the language and help improve it for everybody else. They’ve been able to help track down bugs in the current releases, and also help plan out future iterations.

This has been fantastic for those of us who work with Swift daily, and it would be great to be able to help contribute to the language as well. As it turns out though, programming languages are complicated. Contributing to Swift can be tough without having the time to really learn how it works under the hood. I wanted, for my benefit and for the benefit of others, to start studying the Swift source code and writing up the process as I go.

> I’m learning how Swift works as I go, so some (or all) of this will likely be wrong. Sorry!

### Cloning the Project

The Swift developers include superb documentation for getting up and running with Swift in their [GitHub repo](https://github.com/apple/swift). Assuming you’re on OS X and have an SSH key added to your GitHub account, setting up can be done by running a couple commands:

```
git clone git@github.com:apple/swift.git
cd swift
./utils/update-checkout --clone-with-ssh
```

This will use Swift’s install scripts to update the project and also clone its dependencies, such as LLVM. These dependencies will end up in the same directory level as your Swift repo itself, so it may be worth cloning Swift into its own parent directory in order to keep everything contained.

You can also re-run the `update-checkout --clone-with-ssh` command later to bring everything up to date.

### Running the Tests

A good first start is to run Swift’s tests. Apple again provides an [excellent guide on how to do this](https://github.com/apple/swift/blob/master/docs/Testing.rst).

The basic set of tests can be run with `./utils/build-script --test`. This process takes a little while, but it will build Swift and its dependencies before running through the test suite, giving you progress along the way. At the end, you get a report:

```
Testing Time: 990.31s
  Expected Passes    : 2716
  Expected Failures  : 6
  Unsupported Tests  : 47
-- check-swift-macosx-x86_64 finished --
--- Finished tests for swift ---
```

I’ll revisit the test suite later and explore how it’s set up, as well as how the tests themselves are structured.

### Editing With Xcode

You’ll likely want to edit the source code with Xcode; you can build an Xcode project for Swift by running `utils/build-script -x`. This will build a project for you in the `build` directory (one level up from the Swift source code repo).

It won’t surprise you that there is a _lot_ of stuff in here, so using the fuzzy finder (Command+Shift+O) to find the classes you want is the way to go.

![Swift running in Xcode](https://s3.amazonaws.com/samsymons/images/swift-in-xcode.png)

### Breaking the Tests

Alright! With the boring stuff out of the way, it’s time to make a change to one of the test files and see what an intentional failure looks like. Breaking existing tests is the first step to writing new ones, so let’s get going.

I’m going to pick on the `reverse` function. There is a test file named `CheckSequenceType.swift` (in `swiftStdlibCollectionUnittest-macosx-x86_64`) which houses a variety of tests for collections. In here, you’ll find some tests for `reverse` and friends.

```
public let reverseTests: [ReverseTest] = [
  ReverseTest([], []),
  ReverseTest([ 1 ], [ 1 ]),
  ReverseTest([ 2, 1 ], [ 1, 2 ]),
  ReverseTest([ 3, 2, 1 ], [ 1, 2, 3 ]),
  ReverseTest([ 4, 3, 2, 1 ], [ 1, 2, 3, 4]),
  ReverseTest(
    [ 7, 6, 5, 4, 3, 2, 1 ],
    [ 1, 2, 3, 4, 5, 6, 7 ]),
]
```

Try breaking one of these tests:

```
ReverseTest([ 3, 2, 1 ], [ 3, 2, 1 ]),
```

Since this is a validation test, `./utils/build-script --validation-test` will rebuild and test the suite. So what happens?

```
[ RUN      ] Sequence.reverse/Sequence
check failed at /Users/sasymons/Code/OSS/Swift/swift/stdlib/private/StdlibCollectionUnittest/CheckSequenceType.swift, line 759
stacktrace:
  #0: /Users/sasymons/Code/OSS/Swift/build/Ninja-DebugAssert/swift-macosx-x86_64/validation-test-macosx-x86_64/stdlib/Output/SequenceType.swift.gyb.tmp/Sequence.swift:752
expected: [2, 1] (of type Swift.Array<Swift.Int>)
actual: [1, 2] (of type Swift.Array<Swift.Int>)
[     FAIL ] Sequence.reverse/Sequence
Sequence: Some tests failed, aborting
UXPASS: []
FAIL: ["reverse/Sequence"]
SKIP: []
```

As expected, the tests fail and even provide the offending assertion. Not only that, but the test output will provide a command to run to isolate the failure and fix it. In my case, this is:

```
/Users/sasymons/Code/OSS/Swift/build/Ninja-DebugAssert/swift-macosx-x86_64/validation-test-macosx-x86_64/stdlib/Output/SequenceType.swift.gyb.tmp/a.out --stdlib-unittest-in-process --stdlib-unittest-filter "reverse/Sequence"
```

Undo the change to the `reverse` tests, rebuild Swift, and then run this command to see the tests pass once again. Phew!

### Wrapping Up

Give its complexity, Swift seems very open to new contributors. The scripts are friendly, stable, and there is plenty of documentation on GitHub to get started with.

This is just the beginning, so with the initial introduction to the build system out of the way, we can start looking at how Swift really works.
