Pod::Spec.new do |s|
s.name        = "Johnny"
s.version     = "1.0"
s.summary     = "Elegant Caching in Swift"
s.homepage    = "https://github.com/zolomatok/Johnny"
s.license     = { :type => "MIT" }
s.authors     = { "Zoltán Matók" => "bellamycpt@gmail.com" }

s.osx.deployment_target = "10.10"
s.ios.deployment_target = "8.0"
s.tvos.deployment_target = "9.0"
s.watchos.deployment_target = "2.0"
s.source   = { :git => "https://github.com/zolomatok/Johnny", :tag => "s.version"}
s.source_files = "Johnny/**/*.swift"
s.requires_arc = true
s.module_name = 'Johnny'
s.dependency 'Async', '~> 1.7'
end