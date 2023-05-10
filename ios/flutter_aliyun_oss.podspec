#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_aliyun_oss.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_aliyun_oss'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  
  user_header_paths = [
          '"${PROJECT_DIR}/../'+ $DYProjectFolder + '/protoOC"',
          '"${PROJECT_DIR}/../'+ $DYProjectFolder + '/protoOC/pb"',
          '"${PROJECT_DIR}/../'+ $DYProjectFolder + '/protoOC/client"',
          ]
          
  s.xcconfig = {
      'USER_HEADER_SEARCH_PATHS' => user_header_paths.join(' ')
  }

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
