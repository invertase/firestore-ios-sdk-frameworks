firebase_firestore_version = '10.18.0'

Pod::Spec.new do |s|
  s.name                   = 'FirebaseFirestoreInternalBinary'
  s.version                = firebase_firestore_version
  s.summary                = 'A replica Firebase Firestore podspec.'
  s.description            = 'A replica Firebase Firestore podspec that provides pre-compiled binaries/frameworks instead'
  s.homepage               = 'http://invertase.io'
  s.license                = 'Apache-2.0'

  # See https://github.com/firebase/firebase-ios-sdk/blob/main/Package.swift
  s.source           = {
    :http => 'https://dl.google.com/firebase/ios/bin/firestore/10.18.0/FirebaseFirestoreInternal.zip'
  }

  s.cocoapods_version      = '>= 1.10.0'
  s.authors                = 'Invertase Limited'
  s.pod_target_xcconfig    = { 'OTHER_LDFLAGS' => '-lObjC' }
  s.static_framework       = true

  # These frameworks, minimums, and the c++ library are here from, and copied specifically to match, the upstream podspec:
  # https://github.com/firebase/firebase-ios-sdk/blob/34c4bdbce23f5c6e739bda83b71ba592d6400cd5/FirebaseFirestore.podspec#L103
  # They may need updating periodically.
  s.ios.frameworks         = 'SystemConfiguration', 'UIKit'
  s.osx.frameworks         = 'SystemConfiguration'
  s.tvos.frameworks        = 'SystemConfiguration', 'UIKit'
  s.library                = 'c++'
  s.ios.deployment_target  = '11.0'
  s.osx.deployment_target  = '10.13'
  s.tvos.deployment_target = '12.0'

  s.swift_version = '5.3'

  s.vendored_frameworks = [ 
   "FirebaseFirestoreInternal.xcframework",
  ]

  s.dependency 'FirebaseFirestoreGRPCCPPBinary', '~> 1.49.1'
  s.dependency 'FirebaseFirestoreAbseilBinary', '~> 1.2022062300.0'

  s.dependency 'FirebaseCore', '~> 10.18'
  s.dependency 'leveldb-library', '~> 1.22'
  s.dependency 'nanopb', '>= 2.30908.0', '< 2.30910.0'
end
