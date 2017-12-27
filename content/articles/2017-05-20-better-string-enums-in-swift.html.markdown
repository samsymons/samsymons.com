---
title: "Better String Enums in Swift"
date: "2017-05-20"
tags: swift, objective-c
---

Swift has a number of great features for improving the way it imports Objective-C code. With `NS_SWIFT_NAME` you can customize the name of functions imported into Swift, and nullability annotations let you work closer with Swift's optional system. These features are very useful and pretty well known, but one feature I don't see talked about as often is `NS_STRING_ENUM`.

READMORE

`NS_STRING_ENUM` is a way of taking the usual string-based approach to providing API options and converting it into a much friendlier form. Let's take a look at some simple Objective-C code using string-based enums:

```
#import <Foundation/Foundation.h>

typedef NSString *AnimationDirection NS_STRING_ENUM;

AnimationDirection const AnimationDirectionUp;
AnimationDirection const AnimationDirectionDown;
AnimationDirection const AnimationDirectionLeft;
AnimationDirection const AnimationDirectionRight;
```

Notice that `AnimationDirection` has an `NS_STRING_ENUM` annotation — this is all you need on the Objective-C side for the Swift compiler to convert this into a nicer enum-like form.

With that in an Objective-C header, which is then imported into Swift via a bridging header, you can start writing Swift code in a much cleaner way:

```
func performAnimation(direction: AnimationDirection) {
  // Animate something
}
```

After that, you can call the API as you would expect:

```
performAnimation(direction: .down)
```

### How It Works

Swift imports the `NS_STRING_ENUM` constants as a struct with static properties for its options, in a format similar to this (according to [the Swift and Objective-C interoperability guide](https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html)):

```
struct AnimationDirection: RawRepresentable {
    typealias RawValue = String

    init(rawValue: RawValue)
    var rawValue: RawValue { get }

    static var up: AnimationDirection { get }
    static var down: AnimationDirection { get }
    static var left: AnimationDirection { get }
    static var right: AnimationDirection { get }
}
```

The Swift compiler has a ton of great ways for developers to customize how their Objective-C code is interpreted, and `NS_SWIFT_ENUM` is a fantastic option to have at your disposal. For even more customization, the `NS_EXTENSIBLE_STRING_ENUM` is a similar option which has the same functionality while also making it easier for the generated structs to be extended.
