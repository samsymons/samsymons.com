---

title: Understanding Objective-C Modules
date: 2017-08-03 16:59 UTC
tags: Objective-C, iOS

---

A few years back, the idea of Objective-C modules was introduced to LLVM. They were developed as a solution to the problems associated with the traditional `#include` and `#import` mechanisms.

Since then, modules have crept their way into the Xcode developer ecosystem, becoming even more prevalent with the introduction of Swift. Tools like CocoaPods will even handle module maps for you, if you are installing frameworks to your app — this is why you can set `use_frameworks!` and start importing your Objective-C frameworks just like you would with your Swift ones.

There is a fantastic document on the [rationale behind modules](https://clang.llvm.org/docs/Modules.html#introduction) in the Clang documentation — give that a read if you are interested to learn more about _why_ iOS and Mac developers should pay attention to modules.

### Creating Framework Modules

Xcode makes creating framework modules incredibly easy; for the most part, you don't have to do anything. When you create a new framework target in Xcode, the generated build settings include the `Defines Module` setting set to `Yes`.

> Because modules are set up by default with frameworks, the `#import` and `#include` directives are automatically converted to `@import` behind the scenes, giving you the benefit of modules without any work.

When you build your framework, Xcode will generate a module map that includes the umbrella header. Here is the generated module map for a custom framework target which supports modules:

```
framework module FrameworkModule {
  umbrella header "FrameworkModule.h"

  export *
  module * { export * }
}
```

Some of this syntax may be unfamiliar, since you don't have to deal with module maps often (especially if you're mainly writing Swift), but the language here is fairly small and easy to understand. We'll cover it more in the next section, when we get to writing our own module maps for static libraries.

> Note that the umbrella header here has the same name as the target — this is not a coincidence. For framework targets to generate modules automatically, you will need an umbrella header with the same name as your target.

With your modular framework in place, you can then import it to Swift using `import FrameworkModule`, or into another Objective-C file with `@import FrameworkModule;`.

### Creating Static Library Modules

Xcode comes with great support for automatically generating modules for framework targets, but static libraries are not quite as fortunate. To support modules, you will need to create your own module map and make sure its contents are up to date.

To add a module map, create a new file named `module.modulemap`, and ensure it is added to the `Copy Files` phase of the target.

```
module StaticLibraryModule {
  header "SomeStaticLibraryClass.h"
  export *
}
```

Here, we are defining a module which includes a single header, `SomeStaticLibraryClass.h`. Before you can use it, you need to tell Xcode where to find it. Inside the `Packaging` section of the static library's build settings, there is a `Module Map File` setting — all you need to do here is provided the path to your module map; for example `$(SRCROOT)/StaticLibraryModule/module.modulemap`.

With the module map created and the build settings configured, you are done; by linking this static library with another target, you can use `import StaticLibraryModule` to include `SomeStaticLibraryClass` and anything else you define in the module. The problem is that you likely will not want to have to add each new header file to the module map as you create new files, so instead we can use the umbrella header support.

### Umbrella Headers

With our static library, we will need to add a new header, in this case `StaticLibraryModule.h`. In this, we can include all the files from our module, and easily export them all via the module map.

Here is the definition of the umbrella header:

```objective-c
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT double StaticLibraryModuleVersionNumber;
FOUNDATION_EXPORT const unsigned char StaticLibraryModuleVersionString[];

#import "StaticLibraryModelClass.h"
#import "StaticLibraryNetworkingClass.h"
```

And the updated module map:

```
module StaticLibraryModule {
  umbrella header "StaticLibraryModule.h"
  export *
}
```

With this change, you only need to maintain your header file, and the module map will get those changes for free.

### Submodules

Often, you will want to break a framework up into logical components; if you only need a certain set of classes in a file, it feels wasteful to import the entire module. The module system makes this possible with _submodules_.

Let's break the static library module up into a `Model` module, and a `Networking` module:

```
module StaticLibraryModule {
  export *

  // Define a Model module, which include an example model object class.
  explicit module Model {
    header "StaticLibraryModelClass.h"
  }

  // Define a Networking module, which include an example networking object class.
  // This exports the Model module, meaning that importing the Networking module
  // will implicitly import the Model module along with it.
  explicit module Networking {
    header "StaticLibraryNetworkingClass.h"
    export Model
  }
}
```

The difference with the module declarations here is that they are marked as `explicit`. This means that they aren't available unless they have been explicitly imported (like `import StaticLibraryModule.Model`), or another imported module has re-exported them. You can see this in the `Networking` module, where it includes `export Model` — if you include `Networking`, you get `Model` for free.

Note that the main module declaration is using `export *`, so if you want to gain access to all submodules, you can simply use `import StaticLibraryModule`.

---

You can find the source code for this article [on GitHub](https://github.com/samsymons/Modules).