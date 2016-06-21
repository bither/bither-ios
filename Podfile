source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'

def shared_pods
    pod 'KSCrash', '~> 0.0.3'
    pod 'MKNetworkKit', '~> 0.87'
    pod 'AFNetworking', '~> 2.0'
    pod 'RegexKitLite', '~> 4.0'
    pod 'SimpleKeychain'
    pod 'FXBlurView'
    pod 'OpenSSL', :git => 'https://github.com/bither/OpenSSL.git'
    pod 'Bitheri', :git => 'https://github.com/bither/bitheri.git', :tag => 'v1.6.0'
end

target 'bither-ios' do
    shared_pods
end

target 'bither-ios WatchKit App' do
    pod 'FXBlurView'
end

target 'bither-ios WatchKit Extension' do
    shared_pods
end

target 'bither-iosTests' do
    shared_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
        end
    end
end
