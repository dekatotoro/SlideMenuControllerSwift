Pod::Spec.new do |s|
  s.name         = "SlideMenuControllerSwift"
  s.version      = "2.0.5"
  s.summary      = "iOS Slide View based on iQON, Feedly, Google+, Ameba iPhone app."
  s.homepage     = "https://github.com/ruixingchen/SlideMenuControllerSwift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Yuji Hato" => "hatoyujidev@gmail.com" }
  s.social_media_url   = "https://twitter.com/dekatotoro"
  s.platform     = :ios
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/ruixingchen/SlideMenuControllerSwift.git", :tag => "2.0.5" }
  s.source_files  = "Source/*"
  s.requires_arc = true
end

