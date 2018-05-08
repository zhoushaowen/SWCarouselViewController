Pod::Spec.new do |s|

  s.name         = "SWCarouselViewController"

  s.version      = "2.0.0"

  s.homepage      = 'https://github.com/zhoushaowen/SWCarouselViewController'

  s.ios.deployment_target = '8.0'

  s.summary      = "无限循环轮播图"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "Zhoushaowen" => "348345883@qq.com" }

  s.source       = { :git => "https://github.com/zhoushaowen/SWCarouselView.git", :tag => s.version }
  
  s.source_files  = "SWCarouselView/SWCarouselViewController/*.{h,m}"
  
  s.requires_arc = true

  s.dependency 'SWExtension'

end