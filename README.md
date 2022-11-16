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
 - For Flutter the target is usually called `Runner` and can be added inside the `target 'Runner' do` block in your podfile.
 - For React Native this would be inside the target that has all your local `React-*` pods included.


```ruby
pod 'FirebaseFirestore', :git => 'https://github.com/invertase/firestore-ios-sdk-frameworks.git', :tag => '7.11.0'
```

> **⚠️ Note:** where the tag says `7.11.0` this should be changed to the pod version of `Firebase/Firestore` that you or your dependencies are using - in the format `X.X.X`, for FlutterFire the version that is being used can be seen [here](https://github.com/FirebaseExtended/flutterfire/blob/master/packages/firebase_core/firebase_core/ios/firebase_sdk_version.rb), for React Native Firebase [here](https://github.com/invertase/react-native-firebase/blob/master/packages/app/package.json#L70). If no version is specified on your current `Firebase/Firestore` pod then you can omit `, :tag => '7.11.0'` from the line above and use the latest version on master.

The first time you `pod install` a specific version, CocoaPods will remotely retrieve this git repository at the specifed tag and cache it locally for use as a source for the `FirebaseFirestore` pod.

> **⚠️ Note:** if you were previously caching iOS builds on CI you may now find that when using precompiled binaries that caching is no longer required and it may actually slow down your build times by several minutes. 

### Resolving 'leveldb' missing or duplicate symbol errors

The "leveldb" framework is needed by FirebaseFirestore but may be included in other libraries, so it needs to be included or excluded correctly.
The podspec here attempts to do that for you automatically by default, by detecting known situations where it should be excluded, but sometimes auto-detection fails.

If your build fails due with duplicate 'leveldb' symbols, `pod FirebaseFirestore/WithoutLeveldb` as the pod name instead of `pod FirebaseFirestore`, reinstall pods and try rebuilding.

If your build fails due with missing 'leveldb' symbols, `pod FirebaseFirestore/WithLeveldb` as the pod name instead of `pod FirebaseFirestore`, reinstall pods and try rebuilding.

### Supported Firebase iOS SDK versions

The below are the currently supported Firebase iOS SDK versions of this repository, this list is updated automatically.

> **⚠️ Note:** if you are looking for a new version that is not listed in the supported versions list, examine the upstream release notes for firebase-ios-sdk carefully. This can happen if the firebase-ios-sdk team issues an interim release to solve some urgent problem, but do not run their full release process. If that happens, don't worry - just wait for the next supported version before moving forward, or temporarily de-integrate this pre-compiled framework if you must use the interim version. 6.31.1 is an example of this, with more details [here](https://github.com/firebase/firebase-ios-sdk/pull/6368#issuecomment-685030446) for why it might happen.

<!--NEW_VERSION_PLACEHOLDER-->
 - [10.2.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.2.0)
 - [10.1.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.1.0)
 - [10.0.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.0.0)
 - [9.6.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/9.6.0)
 - [9.5.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/9.5.0)
 - [9.4.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/9.4.0)
 - [9.3.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/9.3.0)
 - [9.2.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/9.2.0)
 - [9.1.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/9.1.0)
 - [9.0.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/9.0.0)
 - [8.15.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.15.0)
 - [8.14.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.14.0)
 - [8.13.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.13.0)
 - [8.12.1](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.12.1)
 - [8.11.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.11.0)
 - [8.10.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.10.0)
 - [8.9.1](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.9.1)
 - [8.9.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.9.0)
 - [8.8.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.8.0)
 - [8.7.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.7.0)
 - [8.6.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.6.0)
 - [8.5.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.5.0)
 - [8.4.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.4.0)
 - [8.3.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.3.0)
 - [8.2.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.2.0)
 - [8.1.1](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.1.1)
 - [8.1.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.1.0)
 - [8.0.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/8.0.0)
 - [7.11.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/7.11.0)
 - [7.10.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/7.10.0)
 - [7.9.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/7.9.0)
 - [7.8.1](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/7.8.1)
 - [7.8.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/7.8.0)
 - [7.7.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/7.7.0)
 - [7.6.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/7.6.0)
 - [7.5.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/7.5.0)
 - [7.4.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/7.4.0)
 - [7.3.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/7.3.0)
 - [7.2.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/7.2.0)
 - [7.1.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/7.1.0)
 - [7.0.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/7.0.0)
 - [6.34.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/6.34.0)
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

<p align="center">
  <a href="https://invertase.io/?utm_source=readme&utm_medium=footer&utm_campaign=firestore-ios-sdk-frameworks">
    <img width="75px" src="https://static.invertase.io/assets/invertase/invertase-rounded-avatar.png">
  </a>
  <p align="center">
    Built and maintained by <a href="https://invertase.io/?utm_source=readme&utm_medium=footer&utm_campaign=firestore-ios-sdk-frameworks">Invertase</a>.
  </p>
</p>
