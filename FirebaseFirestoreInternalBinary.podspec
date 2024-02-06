firebase_firestore_version = '10.21.0'
firebase_firestore_abseil_version = '1.2022062300.0'
firebase_firestore_grpc_version = '1.49.1'
firebase_firestore_grpc_boringssl_version = '1.44.0'
firebase_firestore_leveldb_version = '~> 1.22'
firebase_firestore_nanopb_version_min = '>= 2.30908.0'
firebase_firestore_nanopb_version_max = '< 2.30910.0'

Pod::Spec.new do |s|
  s.name                   = 'FirebaseFirestoreInternalBinary'
  s.version                = firebase_firestore_version
  s.summary                = 'A replica Firebase Firestore podspec.'
  s.description            = 'A replica Firebase Firestore podspec that provides pre-compiled binaries/frameworks instead'
  s.homepage               = 'https://invertase.io'
  s.license                = 'Apache-2.0'

  # See https://github.com/firebase/firebase-ios-sdk/blob/main/Package.swift
  s.source           = {
    :http => "https://dl.google.com/firebase/ios/bin/firestore/#{firebase_firestore_version}/FirebaseFirestoreInternal.zip"
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

  s.dependency 'FirebaseFirestoreGRPCCPPBinary', firebase_firestore_grpc_version
  s.dependency 'FirebaseFirestoreAbseilBinary', firebase_firestore_abseil_version

  s.dependency 'FirebaseCore', firebase_firestore_version
  s.dependency 'leveldb-library', firebase_firestore_leveldb_version
  s.dependency 'nanopb', firebase_firestore_nanopb_version_min, firebase_firestore_nanopb_version_max
end
