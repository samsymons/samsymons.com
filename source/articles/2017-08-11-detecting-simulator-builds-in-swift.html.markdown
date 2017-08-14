---

title: Detecting Simulator Builds in Swift
date: 2017-08-11 23:38 UTC
tags: swift

---

When developing a Swift app, you will occasionally find yourself wanting to include a piece of code only if you're running in the simulator. Perhaps you want to run some alternative code paths (like not calling Metal APIs, which aren't available in the simulator), or avoid attempting to register for push notifications. There are a few ways in which to do this, and the techniques are different depending on whether you're writing Swift or Objective-C.

This difference often catches people out who have come from Objective-C and are used to using all of the familiar C macros. Let's cover the right approach for each language.

READMORE

### The Objective-C Approach

If you're writing Objective-C, this is a breeze to handle. The file `TargetConditionals.h` defines the `TARGET_OS_SIMULATOR` preprocessor macro which you can check like so:

```objective-c
+ (void)checkCurrentDevice {
#if TARGET_OS_SIMULATOR
  NSLog(@"Running in the simulator");
#else
  NSLog(@"Running on a device");
#endif
}
```

Sometimes, you will see `TARGET_IPHONE_SIMULATOR` used instead, which is incorrect — this value is deprecated now, and is defined as `TARGET_OS_SIMULATOR`.

### The Swift Approach

In Swift, this is a little more complicated, as you can't use the `TARGET_OS_SIMULATOR` macro. In fact, per [Apple's documentation](https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html#//apple_ref/doc/uid/TP40014216-CH8-ID31) you can't use C preprocessor macros at all:

>The Swift compiler does not include a preprocessor. Instead, it takes advantage of compile-time attributes, conditional compilation blocks, and language features to accomplish the same functionality. For this reason, preprocessor directives are not imported in Swift.

This is [backed up by Greg Parker](https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160125/007960.html):

> Swift's #if doesn't recognize C macros. `#if TARGET_OS_SIMULATOR` will never be true.

The suggested workaround here is to define a custom flag which is set **only** for simulator builds, the build setting for which can be found under `Active Compilation Conditions` in the custom Swift compiler flags section. Add a sub-setting to the `Debug` setting which targets `Any iOS Simulator SDK` and add your new macro:

[![Xcode displaying the custom simulator flags build setting][custom-flags]][custom-flags]

With the custom `SIMULATOR` flag defined, you can check for it in Swift using `#if`:

```swift
#if SIMULATOR
	print("Running in the simulator")
#endif
```

[custom-flags]: images/custom-simulator-flags.png