Pod::Spec.new do |s|
  s.name             = 'ButtonMerchant'
  s.version          = '0.1.0'
  s.summary          = 'An open source client library for Button merchants.'
  s.description      = <<-DESC
An open source client library for Button merchants.
                       DESC

  s.homepage         = 'https://github.com/button/button-merchant-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = "Button, Inc."
  s.platform         = "ios"
  s.source           = { :git => 'https://github.com/button/button-merchant-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Source/**/*.swift'
end
