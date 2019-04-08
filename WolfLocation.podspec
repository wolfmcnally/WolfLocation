#
# Be sure to run `pod lib lint WolfLocation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WolfLocation'
  s.version          = '1.0.3'
  s.summary          = 'Tools for working with CoreLocation, including iBeacons.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Tools for working with CoreLocation, including iBeacons. Derived from WolfCore.
                       DESC

  s.homepage         = 'https://github.com/wolfmcnally/WolfLocation'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wolfmcnally' => 'wolf@wolfmcnally.com' }
  s.source           = { :git => 'https://github.com/wolfmcnally/WolfLocation.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/wolfmcnally'

  s.swift_version = '5.0'

  s.source_files = 'Sources/WolfLocation/**/*'

  s.ios.deployment_target = '12.0'

  s.dependency 'WolfKit'
end
