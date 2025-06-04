firebase_firestore_version='11.14.0'
firebase_firestore_abseil_url='https://github.com/invertase/firestore-ios-sdk-frameworks/raw/11.14.0/Archives/abseil.zip'
firebase_firestore_abseil_version='1.2024072200.0'
firebase_firestore_grpc_version='1.69.0'
firebase_firestore_grpc_version_url='https://github.com/invertase/firestore-ios-sdk-frameworks/raw/11.14.0/Archives/grpc.zip'
firebase_firestore_grpc_ccp_version_url='https://github.com/invertase/firestore-ios-sdk-frameworks/raw/11.14.0/Archives/grpcpp.zip'
firebase_firestore_leveldb_version='~> 1.22'
firebase_firestore_nanopb_version='~> 3.30910.0'
firebase_firestore_grpc_boringssl_url='https://github.com/invertase/firestore-ios-sdk-frameworks/raw/11.14.0/Archives/openssl.zip'
firebase_firestore_internal_url='https://github.com/invertase/firestore-ios-sdk-frameworks/raw/11.14.0/Archives/firestore_internal.zip'

Pod::Spec.new do |s|
  s.name                   = 'FirebaseFirestoreGRPCBoringSSLBinary'
  s.version                = firebase_firestore_grpc_version
  s.summary                = 'A replica Firebase Firestore podspec.'
  s.description            = 'A replica Firebase Firestore podspec that provides pre-compiled binaries/frameworks instead'
  s.homepage               = 'https://invertase.io'
  s.license                = 'Apache-2.0'

  # See https://github.com/google/grpc-binary/blob/main/Package.swift
  s.source = {
    :http => firebase_firestore_grpc_boringssl_url
  }


  s.cocoapods_version      = '>= 1.12.0'
  s.authors                = 'Invertase Limited'
  s.pod_target_xcconfig    = { 'OTHER_LDFLAGS' => '-lObjC' }

  s.ios.frameworks         = 'SystemConfiguration', 'UIKit'
  s.osx.frameworks         = 'SystemConfiguration'
  s.tvos.frameworks        = 'SystemConfiguration', 'UIKit'
  s.library                = 'c++'
  s.ios.deployment_target  = '13.0'
  s.osx.deployment_target  = '10.15'
  s.tvos.deployment_target = '13.0'

  s.swift_version = '5.3'

  s.resource_bundles = {
    "#{s.module_name}_Privacy" => 'PrivacyInfo.xcprivacy'
  }

  s.vendored_frameworks = [ 
    "openssl_grpc.xcframework",
  ]
end
