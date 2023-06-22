def firebase_sdk_version(framework)
  case framework
  when 'flutter'
    eval(get_github_raw_content('firebase/flutterfire/master/packages/firebase_core/firebase_core/ios/firebase_sdk_version.rb'))
    
    return firebase_sdk_version!
  when 'react-native', 'rn'
    package = JSON.parse(get_github_raw_content('invertase/react-native-firebase/main/packages/app/package.json'))

    return package['sdkVersions']['ios']['firebase']
  else
    puts "Unsupported framework '#{platform.downcase}'! Supported frameworks: flutter, react-native/rn"
  end
end

def get_github_raw_content(path)
  uri = URI("https://raw.githubusercontent.com/#{path}")
  res = Net::HTTP.get_response(uri)
  return res.body
end

def firebase_firebase_pod(framework)
  pod 'FirebaseFirestore', :git => 'https://github.com/invertase/firestore-ios-sdk-frameworks.git', :tag => firebase_sdk_version(framework)
end
