Pod::Spec.new do |s|
  s.name = "ReactiveLists"
  s.version = "0.8.2"

  s.summary = "React-like API for UITableView and UICollectionView"
  s.homepage = "https://github.com/plangrid/ReactiveLists"
  s.license = { :type => "MIT", :file => "LICENSE" }

  s.author = "PlanGrid"
  s.documentation_url = "https://plangrid.github.io/ReactiveLists"
  s.social_media_url = "https://medium.com/plangrid-technology"

  s.source = { :git => "https://github.com/plangrid/ReactiveLists.git", :tag => s.version.to_s }
  s.source_files = 'Sources/**/*.swift'
  s.ios.deployment_target = '11.0'
  s.swift_versions = ['4.2', '5.0']
  s.requires_arc = true

  s.dependency 'DifferenceKit', '~> 1.2.0'
end
