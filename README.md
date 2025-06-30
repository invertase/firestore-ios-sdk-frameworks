# Firestore iOS SDK Binary Distribution

Precompiled Firestore iOS SDK `xcframework` files extracted from the Firebase iOS SDK repository release downloads, tagged by Firebase iOS SDK version and presented as a consumable `podspec`.

## Why

Currently the Firestore iOS SDK depends on some 500k lines of mostly C++, which when compiling as part of your Xcode build takes a long time - even more so in CI environments.

**Related Issues**

- [firebase/firebase-ios-sdk](https://github.com/firebase/firebase-ios-sdk)
  - [#4284](https://github.com/firebase/firebase-ios-sdk/issues/4284) `Adding FirebaseFirestore pod dependency adds minutes to build time`
- [FirebaseExtended/flutterfire](https://github.com/FirebaseExtended/flutterfire)
  - [#349](https://github.com/FirebaseExtended/flutterfire/issues/349) `[cloud_firestore] Xcode build extremely slow`

### Before & After

Before and after timing below, timed when running Xcode build (with cache fully cleared) in a project with Firestore.

**Mac mini (2018) 6 cores**:

```bash
Before:    ~ 240s
After:     ~  45s
```

**GitHub Action CI 2 cores**:

```bash
Before:    ~ 551s
After:     ~ 174s
```

### Usage

Integrating is as simple as adding 1 line to your main target in your projects `Podfile`. Any dependencies in your project that already consume the Firebase iOS SDK from pods will then automatically source Firestore from these precompiled binaries rather than from source.

- For Flutter & React Native this file is usually located at `ios/Podfile`
- For Flutter the target is usually called `Runner` and can be added inside the `target 'Runner' do` block in your podfile.
- For React Native this would be inside the target that has all your local `React-*` pods included.

```ruby
pod 'FirebaseFirestore', :git => 'https://github.com/invertase/firestore-ios-sdk-frameworks.git', :tag => '10.19.0'
```

> **⚠️ Note:** where the tag says `10.19.0` this should be changed to the pod version of `Firebase/Firestore` that you or your dependencies are using - in the format `X.X.X`, for FlutterFire the version that is being used can be seen [here](https://github.com/FirebaseExtended/flutterfire/blob/main/packages/firebase_core/firebase_core/ios/firebase_sdk_version.rb), for React Native Firebase [here](https://github.com/invertase/react-native-firebase/blob/master/packages/app/package.json#L70). If no version is specified on your current `Firebase/Firestore` pod then you can omit `, :tag => '10.19.0'` from the line above and use the latest version on master/main.

The first time you `pod install` a specific version, CocoaPods will remotely retrieve this git repository at the specified tag and cache it locally for use as a source for the `FirebaseFirestore` pod.

> **⚠️ Note:** if you were previously caching iOS builds on CI you may now find that when using precompiled binaries that caching is no longer required and it may actually slow down your build times by several minutes.

### Supported Firebase iOS SDK versions

The below are the currently supported Firebase iOS SDK versions of this repository, this list is updated automatically.

> **⚠️ Note:** if you are looking for a new version that is not listed in the supported versions list, examine the upstream release notes for firebase-ios-sdk carefully. This can happen if the firebase-ios-sdk team issues an interim release to solve some urgent problem, but do not run their full release process. If that happens, don't worry - just wait for the next supported version before moving forward, or temporarily de-integrate this pre-compiled framework if you must use the interim version. 6.31.1 is an example of this, with more details [here](https://github.com/firebase/firebase-ios-sdk/pull/6368#issuecomment-685030446) for why it might happen.

<!--NEW_VERSION_PLACEHOLDER-->
 - [11.15.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.15.0)
 - [11.14.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.14.0)
 - [11.13.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.13.0)
 - [11.12.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.12.0)
 - [11.11.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.11.0)
 - [11.10.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.10.0)
 - [11.9.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.9.0)
 - [11.8.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.8.0)
 - [11.7.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.7.0)
 - [11.6.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.6.0)
 - [11.5.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.5.0)
 - [11.4.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.4.0)
 - [11.3.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.3.0)
 - [11.2.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.2.0)
 - [11.0.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.0.0)
 - [11.0.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.0.0)
 - [11.1.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.1.0)
 - [11.0.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.0.0)
 - [11.0.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.0.0)
 - [11.0.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.0.0)
 - [11.0.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/11.0.0)
 - [10.29.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.29.0)
 - [10.28.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.28.0)
 - [10.27.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.27.0)
 - [10.25.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.25.0)
 - [10.24.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.24.0)
 - [10.23.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.23.0)
 - [10.22.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.22.0)
 - [10.21.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.21.0)
- [10.20.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.20.0)
- [10.19.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.19.0)
- [10.18.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.18.0)
- [10.17.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.17.0)
- [10.16.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.16.0)
- [10.15.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.15.0)
- [10.14.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.14.0)
- [10.13.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.13.0)
- [10.12.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.12.0)
- [10.11.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.11.0)
- [10.10.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.10.0)
- [10.9.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.9.0)
- [10.8.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.8.0)
- [10.7.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.7.0)
- [10.6.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.6.0)
- [10.5.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.5.0)
- [10.4.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.4.0)
- [10.3.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.3.0)
- [10.2.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.2.0)
- [10.1.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.1.0)
- [10.0.0](https://github.com/invertase/firestore-ios-sdk-frameworks/releases/tag/10.0.0)

...and [more](https://github.com/invertase/firestore-ios-sdk-frameworks/tags).

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
