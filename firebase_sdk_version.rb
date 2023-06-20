def firebase_sdk_version(platform)
  case platform
  when 'flutter'
    eval(get_github_raw_content('firebase/flutterfire/master/packages/firebase_core/firebase_core/ios/firebase_sdk_version.rb'))
    
    return firebase_sdk_version!
  when 'react-native', 'rn'
    package = JSON.parse(get_github_raw_content('invertase/react-native-firebase/main/packages/app/package.json'))

    return package['sdkVersions']['ios']['firebase']
  else
    puts "Unsupported platform '#{platform.downcase}'! Supported platforms: flutter, react-native/rn"
  end
end

def get_github_raw_content(path)
  uri = URI("https://raw.githubusercontent.com/#{path}")
  res = Net::HTTP.get_response(uri)
  return res.body
end
