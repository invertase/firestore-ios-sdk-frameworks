firebase_firestore_version = '7.9.0'

Pod::Spec.new do |s|
  s.name             = 'FirebaseFirestore'
  s.version          = firebase_firestore_version
  s.summary          = 'A replica Firebase Firestore podspec.'
  s.description      = 'A replica Firebase Firestore podspec that provides pre-compiled binaries/frameworks instead'
  s.homepage         = 'http://invertase.io'
  s.license          = 'Apache-2.0'
  s.source           = { :path => '.' }
  s.cocoapods_version = '>= 1.10.0'
  s.authors          = 'Invertase Limited'
  s.vendored_frameworks = 'FirebaseFirestore/*.xcframework'
  s.preserve_paths      = 'FirebaseFirestore/*.xcframework'
  s.resource            = 'FirebaseFirestore/Resources/*.bundle'
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
  s.static_framework = true

  # These frameworks and the c++ library are here from, and copied specifically to match, the upstream podspec:
  # https://github.com/firebase/firebase-ios-sdk/blob/34c4bdbce23f5c6e739bda83b71ba592d6400cd5/FirebaseFirestore.podspec#L103
  # They may need updating periodically.
  s.ios.frameworks = 'SystemConfiguration', 'UIKit'
  s.osx.frameworks = 'SystemConfiguration'
  s.tvos.frameworks = 'SystemConfiguration', 'UIKit'
  s.library = 'c++'

  # Skip leveldb framework if Firebase Database is included in any form 
  current_target_definition = Pod::Config.instance.podfile.send(:current_target_definition)
  current_definition_string = current_target_definition.to_hash.to_s

  skip_leveldb = false

  # FlutterFire
  if current_definition_string.include?('firebase_database')
    skip_leveldb = true
  # React native Firebase  
  elsif current_definition_string.include?('RNFBDatabase')
    skip_leveldb = true
  # Pod spec used directly  
  elsif current_definition_string.include?('FirebaseDatabase')
    skip_leveldb = true
  # Umbrella pod spec  
  elsif current_definition_string.include?('Firebase/Database')
    skip_leveldb = true
  end

  if skip_leveldb
    s.exclude_files = 'FirebaseFirestore/leveldb-library.xcframework'
  end
end
