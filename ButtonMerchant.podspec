Pod::Spec.new do |s|
  s.name             = 'ButtonMerchant'
  s.version          = '1.4.3'
  s.summary          = 'An open source client library for Button merchants.'
  s.description      = <<-DESC
The Button Merchant library is a light-weight, open-source method
to complete the App component of your Button Merchant integration
and join the Button Marketplace.
                       DESC

  s.homepage         = 'https://github.com/button/button-merchant-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = "Button, Inc."
  s.platform         = "ios"
  s.source           = { :git => 'https://github.com/button/button-merchant-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'

  s.source_files = 'Source/**/*.{swift,h}'

  s.pod_target_xcconfig = { "SWIFT_VERSION" => 5.0 }
end
