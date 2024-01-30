firebase_firestore_version = '10.20.0'
firebase_firestore_abseil_version = '1202206230'
firebase_firestore_grpc_version = '1.49.1'
firebase_firestore_leveldb_version = '~> 1.22'
firebase_firestore_nanopb_version_min = '>= 2.30908.0'
firebase_firestore_nanopb_version_max = '< 2.30910.0'

Pod::Spec.new do |s|
  s.name                   = 'FirebaseFirestore'
  s.version                = firebase_firestore_version
  s.summary                = 'A replica Firebase Firestore podspec.'
  s.description            = 'A replica Firebase Firestore podspec that provides pre-compiled binaries/frameworks instead'
  s.homepage               = 'https://invertase.io'
  s.license                = 'Apache-2.0'
  s.source                 = { :path => '.' }
  s.cocoapods_version      = '>= 1.10.0'
  s.authors                = 'Invertase Limited'

  s.library                = 'c++'
  s.ios.deployment_target  = '11.0'
  s.osx.deployment_target  = '10.13'
  s.tvos.deployment_target = '12.0'

  s.dependency 'FirebaseFirestoreBinary', firebase_firestore_version
end
