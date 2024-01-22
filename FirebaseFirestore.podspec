firebase_firestore_version = '10.18.0'

Pod::Spec.new do |s|
  s.name                   = 'FirebaseFirestore'
  s.version                = firebase_firestore_version
  s.summary                = 'A replica Firebase Firestore podspec.'
  s.description            = 'A replica Firebase Firestore podspec that provides pre-compiled binaries/frameworks instead'
  s.homepage               = 'http://invertase.io'
  s.license                = 'Apache-2.0'
  s.source                 = { :path => '.' }
  s.cocoapods_version      = '>= 1.10.0'
  s.authors                = 'Invertase Limited'

  s.library                = 'c++'
  s.ios.deployment_target  = '11.0'
  s.osx.deployment_target  = '10.13'
  s.tvos.deployment_target = '12.0'

  s.dependency 'FirebaseFirestoreBinary', '10.18.0'
end
