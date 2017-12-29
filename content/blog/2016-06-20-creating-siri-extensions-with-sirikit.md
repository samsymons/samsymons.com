---
title: Creating Siri Extensions With SiriKit
date: "2016-06-20"
tags: [ "swift", "sirikit" ]
---

With the introduction of iOS 10 at WWDC 2016, Siri has finally been opened up to developers, in the form of [SiriKit](https://developer.apple.com/sirikit/). It comes with support for a fixed set of app categories for now, ranging from messaging and phone calls to payments and booking rides.

Siri is an extremely complicated product, having to manage many languages and process words correctly, so I wanted to see how easy it is to add support for it to an app. I’m going to walk through the entire process of building a basic payments app, covering Intents, the Intents user interface, and the overall SiriKit integration itself.

> Note: Because Siri does not run in the simulator, this sample code will only work on a device running iOS 10.

### Defining the Payments App

Before getting started, I want to go over how the app will be structured. The only two concepts I’m interested in are contacts, the people to whom we will be sending payments, and the payments themselves. This demo won’t persist payments to disk, but you’ll be able to see where that work would be done.

SiriKit integrates nicely with the contacts framework to retrieve the names of people we want to send contacts to, but just to mix it up, the app will provide its own contacts through `INPerson`.

Lastly, I will build a custom UI for our interactions with Siri using the `IntentsUI` framework. I want users to see custom branding and designs for the app, rather than using the generic payments template seen in iOS 10, and Apple makes this easy to do.

If you’d like to follow along, create a new project in Xcode 8 using the single view controller template.

### Laying the Foundations

The Siri extensions are kept separate from the core classes of your app, so a good way to share functionality between them is to set up a framework. Head over to the project navigator and click the `+` in the `Targets` list. You’ll want to create a `Cocoa Touch Framework` here – I’ve named it `PaymentsCore`.

Add a new Swift file to the framework named `PaymentsContact`. This is how the app will represent its contacts, using these classes to expose our user data to Siri.

Here’s my declaration of `PaymentsContact`:

```swift
public class PaymentsContact {
  public let name: String
  public let emailAddress: String

  public init(name: String, emailAddress: String) {
    self.name = name
    self.emailAddress = emailAddress
  }
}
```

Note that because a framework is used here, you have to concern yourself with access control. The class and its user-facing functions must be declared as `public`.

I’ll extend `PaymentsCore` later, but this is enough to get started. Inside the main view controller class, add `import PaymentsCore` and create a new contact object to verify that the framework is set up correctly. If you’re able to access the framework classes from here, using them in SiriKit won’t be a problem.

### Handling Basic Intents

Siri interacts with apps through the `Intents` and `Intents UI` extensions. At the bare minimum, you need to provide an implementation of the first one.

`Intents` is a fairly simple framework. It consists of three main pieces:

1. An Info.plist file, telling Siri where to find your extension handler
2. A subclass of `INExtension`, which verifies that the app is capable of handling a given extension
3. The payments intent handler itself, which takes data from Siri, performs actions with that data, and then tells Siri the results

Head back to the `Targets` list and click the add button again. In here, you should be able to find `Intents Extension` in the application extensions section. Add this, giving it a good name (`PaymentsIntentExtension` for me), though be sure to uncheck the checkbox asking to create a UI extension alongside this one. Those aren’t worth worrying about for now.

This adds a new Intents extension to the project, handling workout intents. I want to handle payment intents, so the first place to look is `Info.plist`. In here, remove the workout intent rows under the `NSExtension` key, and replace them with `INSendPaymentIntent`. This is the end result, copied straight from the `.plist`.

```xml
<dict>
	<key>NSExtensionAttributes</key>
	<dict>
		<key>IntentsRestrictedWhileLocked</key>
		<array>
			<string>INSendPaymentIntent</string>
		</array>
		<key>IntentsSupported</key>
		<array>
			<string>INSendPaymentIntent</string>
		</array>
	</dict>
	<key>NSExtensionPointIdentifier</key>
	<string>com.apple.intents-service</string>
	<key>NSExtensionPrincipalClass</key>
	<string>$(PRODUCT_MODULE_NAME).IntentHandler</string>
</dict>
```

This tells Siri that we want to handle the `INSendPaymentIntent`, that it shouldn’t be available while the phone is locked, and that `IntentHandler` is the class to talk to when asking to handle the payment intent.

Inside `IntentHandler`, I added a short `INExtension` subclass which just checks for the intent type:

```swift
import Intents

class IntentHandler: INExtension {
  override func handler(for intent: INIntent) -> AnyObject? {
    if intent is INSendPaymentIntent {
      return SendPaymentIntentHandler()
    }

    return nil
  }
}
```

`SendPaymentIntentHandler` is a custom class; add a new Swift file to the project, with this as its contents:

```
import Intents

class SendPaymentIntentHandler: NSObject, INSendPaymentIntentHandling {
  // MARK: - INSendPaymentIntentHandling

  func handle(sendPayment intent: INSendPaymentIntent, completion: (INSendPaymentIntentResponse) -> Swift.Void) {
    if let _ = intent.payee, let _ = intent.currencyAmount {
      // Handle the payment here!

      completion(INSendPaymentIntentResponse.init(code: .success, userActivity: nil))
    }
    else {
      completion(INSendPaymentIntentResponse.init(code: .success, userActivity: nil))
    }
  }
}
```

This isn’t really a functional extension yet, but it will actually run with Siri already. If you build the app on your device and say `Send $100 to Tim Cook with Payments`, Siri will attempt to run this through your extension… and fail. The very last piece of the puzzle is to get authorization for Payments to talk to Siri. The app needs to request it, so I’m doing it inside the `ViewController` class:

```
import Intents

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    INPreferences.requestSiriAuthorization() { (status) in
      print("New status: \(status)")
    }
  }
}
```

Run the app to get the authorization prompt, and then fire up Siri to send money to Tim Cook again. This time, you should get a success code back, telling the user that the money was successfully sent! To make it better, just saying `Send $100 to Tim Cook` will ask the user which app to use, presenting Payments in the list of options. Nice!

### Debugging Extensions

Before diving into adding more functionality (including actual _errors_), it’s worth talking about extension debugging. Building and running your app does not allow you to hit breakpoints inside the extension; instead, you need to select `PaymentsIntentExtension` in the list of schemes. When you hit run, you’ll get a list of apps to open this extension with, where you’ll choose Siri.

Once this is running on your phone, launch Siri and give a query to process. If you have a breakpoint set in `SendPaymentIntentHandler` then this should be hit once the query has gone through!

### Checking Contact Data with Siri

Right now, the app is returning a success code for every query. This isn’t very useful, so I’m going to create a canned list of contacts and register these with Siri. I’ll also provide two contacts with different email address but the same name, to demonstrate disambiguating requests.

I’ve added an `allContacts` function to `PaymentsContact`, like this:

```
public class func allContacts() -> [PaymentsContact] {
  return [
    PaymentsContact(name: "Tim Cook", emailAddress: "tim@apple.com"),
    PaymentsContact(name: "Craig Federighi", emailAddress: "craig@apple.com"),
    PaymentsContact(name: "Phil Schiller", emailAddress: "phil@apple.com"),
  ]
}
```

We’ll also need a way to get an `INPerson` object from our contacts. This can be wrapped up in a simple instance function on `PaymentsContact`:

```
public func inPerson() -> INPerson {
  let nameFormatter = PersonNameComponentsFormatter()

  if let nameComponents = nameFormatter.personNameComponents(from: name) {
    return INPerson(handle: emailAddress, nameComponents: nameComponents, contactIdentifier: nil)
  }
  else {
    return INPerson(handle: emailAddress, displayName: name, contactIdentifier: nil)
  }
}
```

Now we can check our `PaymentsContact` objects against the contacts provided by Siri inside `SendPaymentIntentHandler`. The `INSendPaymentIntentHandling` protocol defines another method for resolving the payee of a transaction, in the form of `resolvePayee(intent:completion:)`. This is where the app will take the name provided by Siri and determine what to do with it.

Here’s a basic first pass of the `resolvePayee` function:

```swift
func resolvePayee(forSendPayment intent: INSendPaymentIntent, with completion: (INPersonResolutionResult) -> Swift.Void) {
    if let payee = intent.payee {
      let contacts = PaymentsContact.allContacts()
      var resolutionResult: INPersonResolutionResult?
      var matchedContacts: [PaymentsContact] = []

      for contact in contacts {
        print("Checking '\(contact.name)' against '\(payee.displayName)'")

        if contact.name == payee.displayName {
          matchedContacts.append(contact)
        }
      }

      switch matchedContacts.count {
      case 2 ... Int.max:
        let disambiguationOptions: [INPerson] = matchedContacts.map { contact in
          return contact.inPerson()
        }

        resolutionResult = INPersonResolutionResult.disambiguation(with: disambiguationOptions)
      case 1:
        let recipientMatched = matchedContacts[0].inPerson()
        print("Matched a recipient: \(recipientMatched.displayName)")
        resolutionResult = INPersonResolutionResult.success(with: recipientMatched)
      case 0:
        print("This is unsupported")
        resolutionResult = INPersonResolutionResult.unsupported(with: INIntentResolutionResultUnsupportedReason.none)
      default:
        break
      }

      completion(resolutionResult!)
    } else {
      completion(INPersonResolutionResult.needsValue())
    }
  }
```

You’ll notice that the `completion` handler is responsible for telling Siri how the request was handled. We can tell Siri that the request was unsupported, or that we need a proper value, or even that we found multiple matches and that there is clarification needed.

### Handling Siri Requests In Your App

Not all requests can or should be handled by Siri. Perhaps, for a payments app, you would only want to automatically handle small payments to trusted contacts. If somebody picks up your unlocked phone, they shouldn’t be able to transfer $1000 to themselves with no authentication.

Instead, Siri can be used to start a transaction and then hand that off to the app for completion, where you can authenticate the request fully and verify that it should go through.

Telling Siri to take the user to your app is pretty easy. You do this by providing an `NSUserActivity` object to the `handle` completion block. I added this chunk of code into that function:

```
let userActivity = NSUserActivity()
completion(INSendPaymentIntentResponse.init(code: .success, userActivity: userActivity))
```

Then, in your App Delegate, you can handle the user activity like so:

```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
  if let interaction = userActivity.interaction, let intent = interaction.intent as? INSendPaymentIntent, let payee = intent.payee {
    print("Paying \(payee.displayName) \(intent.currencyAmount!.amount!)")
  }

  return true
}
```

### Displaying an Interface with Siri

Last of all, you will want to display a custom user interface to users to let them know they’ve paid somebody through your app. Instead of using the default Siri payments UI, you can liven things up by providing your own colors and icons.

The only catch is that you can’t use anything interactive; buttons and gesture recognizers won’t work. If you provide the user something to tap on, they might try and tell Siri to do what the button says, leading them to think it’s broken or not doing what they want. Instead, Siri handles all user interaction and forwards it onto your UI.

To add a custom UI, add an extension the same way you added the basic Intent support, but choose Intent UI instead. All you then need to do is modify the newly created `Info.plist` to have the `INSendPaymentIntent` item (removing the default workout intents).

After that, it’s up to you to customise the IntentViewController. The `INUIHostedViewControlling` protocol is how Siri passes information into this class, which you can receive through the `configure` delegate method. Here’s a basic implementation:

```swift
func configure(with interaction: INInteraction!, context: INUIHostedViewContext, completion: ((CGSize) -> Void)!) {
    if let sendIntent = interaction.intent as? INSendPaymentIntent {
      if let payee = sendIntent.payee {
        // Do something with payee.displayName
      }

      completion(self.desiredSize)
    }
    else {
      completion(self.desiredSize)
    }
  }
```

`desiredSize` is a function provided by the boilerplate class generated when you added this extension; it works by returning a `CGSize`. You can provide `self.extensionContext!.hostedViewMaximumAllowedSize` to give the largest size allowed, or the equivalent `hostedViewMinimumAllowedSize` for the opposite. On an iPhone 6, this gives a height range of 120 points up to 200 points. Width scales to the size of the device.

### Conclusion

There’s still a lot to learn with SiriKit. I haven’t yet tested out sharing data between Siri extensions and the core app, or done a lot with handing off an interaction from Siri to the app, but this is still a fresh API. I’ll likely update the demo app as I continue to learn more, so check back on that if you’re curious to see how SiriKit works a little more in-depth.

You can get the source code for this article [on GitHub](https://github.com/samsymons/Payments).
