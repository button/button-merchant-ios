platform :ios, '9.0'
use_frameworks!

pod 'SwiftLint'

target 'Example' do
  pod 'ButtonMerchant', :path => './'
  pod 'Sourcery'
end

target 'Example-ObjC' do
    pod 'ButtonMerchant', :path => './'
end

target 'ButtonMerchant' do
end

target 'UnitTests' do
end

target 'IntegrationTests' do
end

post_install do |installer|
    podspec = JSON.parse(`pod ipc spec ./ButtonMerchant.podspec`)
    version = podspec["version"]
    `Pods/Sourcery/bin/sourcery --templates .templates/Version.stencil --sources . --output Source/Version/ --args version=#{version}`
    `Pods/Sourcery/bin/sourcery --templates .templates/VersionTests.stencil --sources . --output Tests/UnitTests/Version/ --args version=#{version}`
    `/usr/libexec/PlistBuddy -c "set :CFBundleShortVersionString '#{version}'" Source/Info.plist`
end
