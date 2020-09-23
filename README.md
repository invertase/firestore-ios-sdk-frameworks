## Firestore iOS SDK

Precompiled Firestore iOS SDK `xcframework` files extracted from the Firebase iOS SDK repository release downloads, tagged by Firebase iOS SDK version and presented as a consumable `podspec`.

### Why

Currently the Firestore iOS SDK depends on some 500k lines of mostly C++, which when compiling as part of your Xcode build takes a long time - even more so in CI environments.

**Related Issues**

- [firebase/firebase-ios-sdk](https://github.com/firebase/firebase-ios-sdk)
  - [#4284](https://github.com/firebase/firebase-ios-sdk/issues/4284) `Adding FirebaseFirestore pod dependency adds minutes to build time`
- [FirebaseExtended/flutterfire](https://github.com/FirebaseExtended/flutterfire)
  - [#349](https://github.com/FirebaseExtended/flutterfire/issues/349) `[cloud_firestore] Xcode build extremely slow`
  
#### Before & After

Before and after timing below, timed when running Xcode build (with cache fully cleared) in a project with Firestore.

**Mac mini (2018) 6 cores**:

```
Before:    ~ 240s
After:     ~  45s
```

**GitHub Action CI 2 cores**:

```
Before:    ~ 551s
After:     ~ 174s
```

### Usage

Integrating is as simple as adding 1 line to your main target in your projects `Podfile`. Any dependencies in your project that already consume the Firebase iOS SDK from pods will then automatically source Firestore from these precompiled binaries rather than from source.

 - For Flutter & React Native this file is usually located at `ios/Podfile`
 - For Futter the target is usually called `Runner` and can be added inside the `target 'Runner' do` block in your podfile.
 - For React Native this would be inside the target that has all your local `React-*` pods included.


```ruby
pod 'FirebaseFirestore', :git => 'https://github.com/invertase/firestore-ios-sdk-frameworks.git', :tag => '6.26.0'
```

> **⚠️ Note:** where the tag says `6.26.0` this should be changed to the pod version of `Firebase/Firestore` that you or your dependencies are using - in the format `X.X.X`, for FlutterFire the version that is being used can be seen [here](https://github.com/FirebaseExtended/flutterfire/blob/master/packages/cloud_firestore/cloud_firestore/ios/cloud_firestore.podspec), for React Native Firebase [here](https://github.com/invertase/react-native-firebase/blob/master/packages/app/package.json#L70). If no version is specified on your current `Firebase/Firestore` pod then you can emit `, :tag => '6.26.0'` from the line above and use the latest version on master.

The first time you `pod install` a specific version, CocoaPods will remotely retrieve this git repository at the specifed tag and cache it locally for use as a source for the `FirebaseFirestore` pod.

> **⚠️ Note:** if you were previously caching iOS builds on CI you may now find that when using precompiled binaries that caching is no longer required and it may actually slow down your build times by several minutes. 

### Supported Firebase iOS SDK versions

The below are the currently supported Firebase iOS SDK versions of this repository, this list is updated automatically.

> **⚠️ Note:** if you are looking for a new version that is not listed in the supported versions list, examine the upstream release notes for firebase-ios-sdk carefully. This can happen if the firebase-ios-sdk team issues an interim release to solve some urgent problem, but do not run their full release process. If that happens, don't worry - just wait for the next supported version before moving forward, or temporarily de-integrate this pre-compiled framework if you must use the interim version. 6.31.1 is an example of this, with more details [here](https://github.com/firebase/firebase-ios-sdk/pull/6368#issuecomment-685030446) for why it might happen.

<!--NEW_VERSION_PLACEHOLDER-->
 - [6.33.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/6.33.0)
 - [6.32.2](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/6.32.2)
 - [6.32.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/6.32.0)
 - [6.31.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/6.31.0)
 - [6.30.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/6.30.0)
 - [6.29.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/6.29.0)
 - [6.28.1](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/6.28.1)
 - [6.28.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/6.28.0)
 - [6.27.1](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/6.27.1)
 - [6.27.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/6.27.0)
 - [6.26.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/6.26.0)
 - [6.25.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/6.25.0)
 - [6.24.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/6.24.0)
 - [6.23.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/6.23.0)
 - [6.22.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/6.22.0)
 - [6.21.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/6.21.0)

## License

- See [LICENSE](/LICENSE)

---

<p>
  <img align="left" width="75px" src="https://static.invertase.io/assets/invertase-logo-small.png">
  <p align="left">
    Built and maintained with 💛 by <a href="https://invertase.io">Invertase</a>.
  </p>
  <p align="left">
    <a href="https://twitter.com/invertaseio"><img src="https://img.shields.io/twitter/follow/invertaseio.svg?style=flat-square&colorA=1da1f2&colorB=&label=Follow%20on%20Twitter" alt="Follow on Twitter"></a>
  </p>
</p>

---
