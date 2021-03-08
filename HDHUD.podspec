Pod::Spec.new do |s|
s.name = 'HDHUD'
s.swift_version = '5.0'
s.version = '1.2.3'
s.license= { :type => "MIT", :file => "LICENSE" }
s.summary = 'A simple and efficient HUD based on swift development'
s.homepage = 'https://github.com/DamonHu/HDHUD'
s.authors = { 'DamonHu' => 'dong765@qq.com' }
s.source = { :git => "https://github.com/DamonHu/HDHUD.git", :tag => s.version}
s.requires_arc = true
s.ios.deployment_target = '10.0'
s.source_files = "HDHUD/Pod/Class/*.swift"
# s.resources = "HDHUD/Pod/Assets/*.png"
s.resource_bundles = {
  'HDHUD' => ['HDHUD/Pod/Assets/*.png', 'HDHUD/Pod/Assets/*.gif']
}
s.frameworks = 'UIKit'
s.documentation_url = 'https://github.com/DamonHu/HDHUD'

s.dependency 'HDCommonToolsSwift'
s.dependency 'SnapKit'
s.dependency 'Kingfisher'
end