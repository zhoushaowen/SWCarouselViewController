Pod::Spec.new do |s|

  s.name         = "SWCarouselView"

  s.version      = "1.1.0"

  s.homepage      = 'https://github.com/zhoushaowen/SWCarouselView'

  s.ios.deployment_target = '8.0'

  s.summary      = "无限循环轮播图"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "Zhoushaowen" => "348345883@qq.com" }

  s.source       = { :git => "https://github.com/zhoushaowen/SWCarouselView.git", :tag => s.version }
  
  s.source_files  = "SWCarouselView/SWCarouselView/*.{h,m}"
  
  s.requires_arc = true

  s.dependency 'SWExtension'

end