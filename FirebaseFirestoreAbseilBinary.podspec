firebase_firestore_version = '10.20.0'
firebase_firestore_abseil_version = '1202206230'
firebase_firestore_grpc_version = '1.49.1'
firebase_firestore_leveldb_version = '~> 1.22'
firebase_firestore_nanopb_version_min = '>= 2.30908.0'
firebase_firestore_nanopb_version_max = '< 2.30910.0'

Pod::Spec.new do |s|
  s.name                   = 'FirebaseFirestoreAbseilBinary'
  s.version                = firebase_firestore_abseil_version
  s.summary                = 'Binary build of Firestore abseil dependency'
  s.description            = 'Not supported for usage outside of Firebase.'
  s.homepage               = 'https://invertase.io'
  s.license                = 'Apache-2.0'

  # See https://github.com/google/abseil-cpp-binary/blob/main/Package.swift
  s.source           = {
    :http => 'https://dl.google.com/firebase/ios/bin/abseil/#{firebase_firestore_abseil_version}/abseil.zip'
  }

  s.cocoapods_version      = '>= 1.10.0'
  s.authors                = 'Invertase Limited'
  s.pod_target_xcconfig    = { 'OTHER_LDFLAGS' => '-lObjC' }

  s.ios.frameworks         = 'SystemConfiguration', 'UIKit'
  s.osx.frameworks         = 'SystemConfiguration'
  s.tvos.frameworks        = 'SystemConfiguration', 'UIKit'
  s.library                = 'c++'
  s.ios.deployment_target  = '11.0'
  s.osx.deployment_target  = '10.13'
  s.tvos.deployment_target = '12.0'

  s.swift_version = '5.3'

  s.vendored_frameworks = [ 
    "abseil.xcframework",
  ]
end
