firebase_firestore_version = '1.12.0'

Pod::Spec.new do |s|
  s.name             = 'FirebaseFirestore'
  s.version          = firebase_firestore_version
  s.summary          = 'A replica Firebase Firestore podspec.'
  s.description      = 'A replica Firebase Firestore podspec that provides pre-compiled binaries/frameworks instead'
  s.homepage         = 'http://invertase.io'
  s.license          = 'Apache-2.0'
  s.source           = { :path => '.' }
  s.authors          = 'Invertase Limited'
  s.vendored_frameworks = 'FirebaseFirestore/*.xcframework'
  s.preserve_paths      = 'FirebaseFirestore/*.xcframework'
  s.resource            = 'FirebaseFirestore/Resources/*.bundle'
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
  s.static_framework = true
end
