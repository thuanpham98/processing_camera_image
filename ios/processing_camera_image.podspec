#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint processing_camera_image.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'processing_camera_image'
  s.version          = '0.0.1'
  s.summary          = 'A flutter plugin for process fast camera image from plugin camera of google'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://github.com/thuanpham98/processing_camera_image'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'thuanpm' => 'pmttmp24@gmail.com' }
  s.source           = { :path => '.' }
  s.public_header_files = 'Classes/**/*.h'
  s.source_files = ['Classes/**/*', 'native/**/*.{c,h}',]
  # s.public_header_files = 'Classes/ProcessingCameraImagePlugin.h'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'HEADER_SEARCH_PATHS' => [
    '$(PODS_TARGET_SRCROOT)/native',
  ],
  'DEFINES_MODULE' => 'YES', 
  'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
