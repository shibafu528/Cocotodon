# Uncomment the next line to define a global platform for your project
platform :osx, '11.1'

target 'Cocotodon' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'AFNetworking', '~> 4.0'
  pod 'Mantle'
  pod 'PromiseKit', '~> 6.8'
  pod 'Punycode-Cocoa', '~> 1.3'
  pod 'Sparkle', '~> 1.26'
  pod 'twitter-text', '~> 3.1'
end

target 'JokeDiagnosisKit' do
  use_frameworks!

  pod 'PromiseKit', '~> 6.8'
  pod 'Fuzi', '~> 3.1.3'

  target 'JokeDiagnosisKitTests' do
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '11.1'
    end
  end
end
