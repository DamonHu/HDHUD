Pod::Spec.new do |s|
s.name = 'HDHUD'
s.swift_version = '5.0'
s.version = '3.0.1'
s.license= { :type => "MIT", :file => "LICENSE" }
s.summary = 'A simple and efficient HUD based on swift development'
s.homepage = 'https://github.com/DamonHu/HDHUD'
s.authors = { 'DamonHu' => 'dong765@qq.com' }
s.source = { :git => "https://github.com/DamonHu/HDHUD.git", :tag => s.version}
s.requires_arc = true
s.ios.deployment_target = '12.0'
s.subspec 'core' do |cs|
  cs.resource_bundles = {
    'HDHUD' => ['pod/Assets/*.png','pod/Assets/**/*.png', 'HDHUD/Pod/Assets/*.gif']
  }
  cs.source_files = "pod/Class/*.swift"
  cs.dependency 'SnapKit', '~> 5.0'
  cs.dependency 'DDUtils/ui', '~> 5.0'
end
s.default_subspec = "core"
s.frameworks = 'UIKit'
s.documentation_url = 'https://github.com/DamonHu/HDHUD'
end