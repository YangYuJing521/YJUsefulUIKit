#
# Be sure to run `pod lib lint YJUsefulUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YJUsefulUIKit'
  s.version          = '1.0.0'
  s.summary          = 'A short description of YJUsefulUIKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/YangYuJing521/YJUsefulUIKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'YangYuJing521' => 'ios_yangyujing@163.com' }
  s.source           = { :git => 'https://github.com/YangYuJing521/YJUsefulUIKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'YJUsefulUIKit/Classes/YJUsefulUIKit.h'
  
  s.resource_bundles = {
    'YJUsefulUIKit' => ['YJUsefulUIKit/Assets/*/*.png']
  }
  
  s.subspec 'YJBaseCells' do |ss|
  ss.source_files = 'YJUsefulUIKit/Classes/YJBaseCells/*'
  ss.frameworks = 'UIKit', 'Foundation'
  ss.dependency 'YJUsefulUIKit/YJUICommon'
  end

  s.subspec 'YJNocrash' do |aa|
  aa.source_files = 'YJUsefulUIKit/Classes/YJNocrash/*'
  aa.frameworks = 'UIKit', 'Foundation'
  end
  
  s.subspec 'YJToast' do |bb|
  bb.source_files = 'YJUsefulUIKit/Classes/YJToast/*'
  bb.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
  end

  s.subspec 'YJUICommon' do |cc|
  cc.source_files = 'YJUsefulUIKit/Classes/YJUICommon/*'
  cc.frameworks = 'UIKit', 'Foundation'
  cc.dependency 'YJUsefulUIKit/YJNocrash'
  end
  
   s.subspec 'YJExtension' do |dd|
   dd.source_files = 'YJUsefulUIKit/Classes/YJExtension/*'
   dd.frameworks = 'UIKit', 'Foundation', 'CoreText'
   dd.dependency 'YYCategories'
   dd.dependency 'YJUsefulUIKit/YJUICommon'
   end

   s.subspec 'YJCycleScrollow' do |ee|
   ee.source_files = 'YJUsefulUIKit/Classes/YJCycleScrollow/*'
   ee.frameworks = 'UIKit', 'Foundation'
   ee.dependency 'YJUsefulUIKit/YJUICommon'
   ee.dependency 'SDWebImage'
   end


   s.subspec 'YJProgressWKWebView' do |ff|
   ff.source_files = 'YJUsefulUIKit/Classes/YJProgressWKWebView/*'
   ff.frameworks = 'UIKit', 'Foundation', 'WebKit'
   ff.dependency 'Masonry'
   end

   s.subspec 'YJGuidePageView' do |gg|
   gg.source_files = 'YJUsefulUIKit/Classes/YJGuidePageView/*'
   gg.frameworks = 'UIKit', 'Foundation'
   end

   s.subspec 'YJBasicDepand' do |hh|
   hh.source_files = 'YJUsefulUIKit/Classes/YJBasicDepand/*'
   hh.frameworks = 'UIKit'
   hh.dependency 'YJUsefulUIKit/YJUICommon'
   hh.dependency 'YJUsefulUIKit/YJExtension'
   end


  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
