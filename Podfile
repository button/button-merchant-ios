platform :ios, '9.0'
use_frameworks!

pod 'SwiftLint'

target 'Example' do
end

target 'Example-ObjC' do
end

target 'UnitTests' do
end

target 'IntegrationTests' do
end

post_install do |installer|
    podspec = JSON.parse(`pod ipc spec ./ButtonMerchant.podspec`)
    version = podspec["version"]
    version_file = 'Source/Version/Version.generated.swift'
    version_test_file = 'Tests/UnitTests/Version/VersionTests.generated.swift'
    File.write(version_file, File.read(version_file).gsub(/\d+.\d+.\d+/, version))
    File.write(version_test_file, File.read(version_test_file).gsub(/\d+.\d+.\d+/, version))
    `/usr/libexec/PlistBuddy -c "set :CFBundleShortVersionString '#{version}'" Source/Info.plist`
    
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      end
    end
end
