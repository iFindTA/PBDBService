Pod::Spec.new do |s|
  s.name         = "PBDBService"
  s.version      = "1.1.0"
  s.summary      = "database service for iOS development."
  s.description  = "database service for FLK.Inc iOS Developers, such as SQLCipher/FTS etc."
  s.homepage     = "https://github.com/iFindTA"
  s.license      = "MIT (LICENSE)"
  s.author             = { "nanhujiaju" => "hujiaju@hzflk.com" }
  s.platform     = :ios, "8.0"
  
  s.source       = { :git => "https://github.com/iFindTA/PBDBService.git", :tag => "#{s.version}" }
  s.source_files  = "PBDBService/Pod/Classes/*.{h,m}"
  s.public_header_files = "PBDBService/Pod/Classes/*.h"
  
  #s.resources    = "FLKNetServicePro/FLKNetService/Certs/*.cer"
  
  #s.libraries    = "CommonCrypto"
  s.frameworks  = "UIKit","Foundation","SystemConfiguration"
  # s.frameworks = "SomeFramework", "AnotherFramework"
  
  s.requires_arc = true
  
  #s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/CommonCrypto,$(SRCROOT)/FLKNetService/Core","CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES" =>"YES","ONLY_ACTIVE_ARCH" => "NO"}
  #s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include","CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES" =>"YES","ONLY_ACTIVE_ARCH" => "NO"}
  
  #s.dependency "JSONKit", "~> 1.4"
  s.dependency 'FMDB/FTS', '~> 2.6.2'
  s.dependency 'FMDB/SQLCipher', '~> 2.6.2'
end