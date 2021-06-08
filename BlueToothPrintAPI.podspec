#
# Be sure to run `pod lib lint BlueToothPrintAPI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BlueToothPrintAPI'
  s.version          = '0.1.0'
  s.summary          = 'BlueToothPrintAPI is a print SDK with BlueTooth, you just send you print info with a method, then you can get call back from the print!'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: BlueToothPrintAPI is a print SDK with BlueTooth, you just send you print info with a method, then you can get call back from the print!
                       DESC

  s.homepage         = 'https://github.com/yonghuifan21/BlueToothPrintAPI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yonghuifan21' => 'andy_yonghui@163.com' }
  s.source           = { :git => 'https://github.com/yonghuifan21/BlueToothPrintAPI.git', :tag => s.version.to_s }

  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.platform      = :ios, '9.0'  #支持的平台
  s.ios.deployment_target = '9.0'

  s.source_files = 'BlueToothPrintAPI/Classes/**/*'
  
  # s.resource_bundles = {
  #   'BlueToothPrintAPI' => ['BlueToothPrintAPI/Assets/*.png']
  # }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  
  s.dependency 'WebViewJavascriptBridge', '~> 6.0'
  s.dependency 'SSZipArchive', '~> 2.4.2'
  s.dependency 'BabyBluetooth','~> 0.7.0'

end
