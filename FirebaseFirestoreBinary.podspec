firebase_firestore_version = '10.20.0'
firebase_firestore_abseil_version = '1.20220623.0'
firebase_firestore_grpc_version = '1.49.1'
firebase_firestore_grpc_boringssl_version = '1.44.0'
firebase_firestore_leveldb_version = '~> 1.22'
firebase_firestore_nanopb_version_min = '>= 2.30908.0'
firebase_firestore_nanopb_version_max = '< 2.30910.0'

Pod::Spec.new do |s|
  s.name             = 'FirebaseFirestoreBinary'
  s.version          = firebase_firestore_version
  s.summary          = 'Google Cloud Firestore'
  s.description      = <<-DESC
Google Cloud Firestore is a NoSQL document database built for automatic scaling, high performance, and ease of application development.
                       DESC
  s.homepage         = 'https://developers.google.com/'
  s.license          = { :type => 'Apache-2.0', :file => 'Firestore/LICENSE' }
  s.authors          = 'Google, Inc.'
  s.source           = {
    :git => 'https://github.com/invertase/firestore-ios-sdk-frameworks.git',
    :tag => s.version.to_s
  }

  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'
  s.tvos.deployment_target = '12.0'
  s.static_framework = true
  s.module_name = 'FirebaseFirestore'
  s.header_dir = 'FirebaseFirestore'

  s.swift_version = '5.3'

  s.weak_framework = 'FirebaseFirestoreInternal'

  s.cocoapods_version = '>= 1.4.0'
  s.prefix_header_file = false

  s.public_header_files = 'FirebaseFirestoreInternal/**/*.h'

  s.requires_arc            = true
  s.source_files = [
    'FirebaseFirestoreInternal/**/*.[mh]',
    'Firestore/Swift/Source/**/*.swift',
  ]

  s.dependency 'FirebaseCore', firebase_firestore_version
  s.dependency 'FirebaseCoreExtension', firebase_firestore_version
  s.dependency 'FirebaseFirestoreInternalBinary', firebase_firestore_version
  s.dependency 'FirebaseSharedSwift', firebase_firestore_version

end
