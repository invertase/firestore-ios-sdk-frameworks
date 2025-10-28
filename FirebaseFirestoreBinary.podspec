firebase_firestore_version='12.5.0'
firebase_firestore_abseil_url='https://github.com/invertase/firestore-ios-sdk-frameworks/raw/12.5.0/Archives/abseil.zip'
firebase_firestore_abseil_version='1.2024072200.0'
firebase_firestore_grpc_version='1.69.0'
firebase_firestore_grpc_version_url='https://github.com/invertase/firestore-ios-sdk-frameworks/raw/12.5.0/Archives/grpc.zip'
firebase_firestore_grpc_ccp_version_url='https://github.com/invertase/firestore-ios-sdk-frameworks/raw/12.5.0/Archives/grpcpp.zip'
firebase_firestore_leveldb_version='~> 1.22'
firebase_firestore_nanopb_version='~> 3.30910.0'
firebase_firestore_grpc_boringssl_url='https://github.com/invertase/firestore-ios-sdk-frameworks/raw/12.5.0/Archives/openssl.zip'
firebase_firestore_internal_url='https://github.com/invertase/firestore-ios-sdk-frameworks/raw/12.5.0/Archives/firestore_internal.zip'

Pod::Spec.new do |s|
  s.name             = 'FirebaseFirestoreBinary'
  s.version          = firebase_firestore_version
  s.summary          = 'Google Cloud Firestore'
  s.description      = <<-DESC
Google Cloud Firestore is a NoSQL document database built for automatic scaling, high performance, and ease of application development.
                       DESC
  s.homepage         = 'https://developers.google.com/'
  s.license          = 'Apache-2.0'
  s.authors          = 'Google, Inc.'
  s.source           = {
    :git => 'https://github.com/firebase/firebase-ios-sdk.git',
    :tag => 'CocoaPods-' + s.version.to_s
  }

  s.ios.frameworks = 'SystemConfiguration', 'UIKit'
  s.osx.frameworks = 'SystemConfiguration'
  s.tvos.frameworks = 'SystemConfiguration', 'UIKit'

  s.ios.deployment_target  = '15.0'
  s.osx.deployment_target  = '10.15'
  s.tvos.deployment_target = '15.0'
  s.static_framework = true
  s.module_name = 'FirebaseFirestore'
  s.header_dir = 'FirebaseFirestore'

  s.swift_version = '5.3'

  s.weak_framework = 'FirebaseFirestoreInternal'

  s.cocoapods_version = '>= 1.12.0'
  s.prefix_header_file = false

  s.public_header_files = 'FirebaseFirestoreInternal/**/*.h'
  s.requires_arc            = true
  s.source_files = [
    'FirebaseFirestoreInternal/**/*.[mh]',
    'Firestore/Swift/Source/**/*.swift',
  ]

  s.resource_bundles = {
    "#{s.module_name}_Privacy" => 'Firestore/Swift/Source/Resources/PrivacyInfo.xcprivacy'
  }

  s.dependency 'FirebaseCore', firebase_firestore_version
  s.dependency 'FirebaseCoreExtension', firebase_firestore_version
  s.dependency 'FirebaseFirestoreInternalBinary', firebase_firestore_version
  s.dependency 'FirebaseSharedSwift', firebase_firestore_version

end
