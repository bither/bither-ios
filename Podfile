source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

def shared_pods
    pod 'KSCrash', '~> 0.0.3'
    pod 'AFNetworking', '~> 4.0'
    pod 'RegexKitLite', '~> 4.0'
    pod 'SimpleKeychain'
    pod 'FXBlurView'
    pod 'OpenSSL', :git => 'https://github.com/bither/OpenSSL.git'
    pod 'Bitheri', :git => 'https://github.com/bither/bitheri.git', :branch => 'develop'
end

target 'bither-ios' do
    shared_pods
end

target 'bither-iosTests' do
    shared_pods
end

def patch_private_headers(installer)
  source_pattern = File.join(installer.sandbox.root.to_s, '**', '*.{h,m,mm}')
  private_header = /^[ \t]*#[ \t]*(?:import|include)[ \t]+[<"]netinet6\/in6\.h[>"][ \t]*(?:\r?\n|\z)/

  Dir.glob(source_pattern).each do |file|
    next unless File.file?(file)

    content = File.read(file)
    patched_content = content.gsub(private_header, '')
    next if patched_content == content

    File.chmod(File.stat(file).mode | 0200, file)
    File.write(file, patched_content)
  end
end

post_install do |installer|
    patch_private_headers(installer)
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
        end
    end
end
