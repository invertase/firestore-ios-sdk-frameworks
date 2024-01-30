firebase_firestore_version = '10.18.0'
firebase_firestore_abseil_version = '1.2022062300.0'
firebase_firestore_grpc_version = '1.49.1'

Pod::Spec.new do |s|
  s.name                   = 'FirebaseFirestoreGRPCBoringSSLBinary'
  s.version                = firebase_firestore_grpc_version
  s.summary                = 'A replica Firebase Firestore podspec.'
  s.description            = 'A replica Firebase Firestore podspec that provides pre-compiled binaries/frameworks instead'
  s.homepage               = 'https://invertase.io'
  s.license                = 'Apache-2.0'

  # See https://github.com/google/grpc-binary/blob/main/Package.swift
  s.source           = {
    :http => 'https://dl.google.com/firebase/ios/bin/grpc/#{firebase_firestore_grpc_version}/BoringSSL-GRPC.zip'
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
    "BoringSSL-GRPC.xcframework",
  ]
end
