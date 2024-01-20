Pod::Spec.new do |s|
  s.name             = 'FirebaseFirestoreBinary'
  s.version          = '10.20.0'
  s.summary          = 'Google Cloud Firestore'
  s.description      = <<-DESC
Google Cloud Firestore is a NoSQL document database built for automatic scaling, high performance, and ease of application development.
                       DESC
  s.homepage         = 'https://developers.google.com/'
  s.license          = { :type => 'Apache-2.0', :file => 'Firestore/LICENSE' }
  s.authors          = 'Google, Inc.'
  s.source           = {
    :git => 'https://github.com/firebase/firebase-ios-sdk.git',
    :tag => 'CocoaPods-' + s.version.to_s
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

  s.dependency 'FirebaseCore', '~> 10.20'
  s.dependency 'FirebaseCoreExtension', '~> 10.20'
  s.dependency 'FirebaseFirestoreInternalBinary', '~> 10.20'
  s.dependency 'FirebaseSharedSwift', '~> 10.20'

end
