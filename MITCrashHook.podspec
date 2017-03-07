
Pod::Spec.new do |s|
  s.name         = 'MitCrashHook'
  s.version      = '0.0.1'
  s.summary      = 'MitCrashHook summary'
  s.homepage     = 'https://github.com/mcmengchen'
  s.license      = 'MIT'
  s.authors      = {'mcmengchen' => '416922992@qq.com'}
  s.platform     = :ios, '7.0'
  s.source       = {:git => 'https://github.com/mcmengchen/MitHookCrash.git', :tag => s.version}
  s.source_files = 'MitCrashHook/*.{h,m}'
  s.frameworks   = 'UIKit', 'Foundation'
  s.requires_arc = true
end
