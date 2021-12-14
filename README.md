# candied-yams

A thin wrapper around the plain objects API of [Yams](https://github.com/jpsim/Yams.git) to make it usable from Objective-C

## Usage

1. Clone this repository somewhere within your project directory. It is up to you to keep the clone up to date by whatever means, such as making it a submodule.
1. In Xcode, right-click in your project's file hierarchy and choose "Add Files...". Select `candied-yams.xcodeproj`.
1. Add `CandiedYams.framework` to your target's Linked Frameworks and Libraries.
1. In Objective-C wishing to use Yams, add `@import CandiedYams.Swift;` or `#import <CandiedYams/CandiedYams-Swift.h>` to your header inclues.
1. Call any of the static methods on the `CandiedYams` class. No other APIs are provided by this framework.

## Notes:

I don't know offhand if it's possible to build this framework statically, due to its embedding of a Swift module. If you really want to avoid the separate framework, just embed the source code of both the Yams package and this project directly into your app target.

This is not much more than a proof of concept. No guarantee of correctness, functionality, or even accuracy of this README is given. Use at your own risk.

Issues and PRs are welcome, but would be a little surprising given how uninteresting this project really is :).

