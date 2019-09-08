Pod::Spec.new do |s|
    s.name        = "Johnny"
    s.version     = "3.0.4"
    s.summary     = "Melodic Caching in Swift"
    s.homepage    = "https://github.com/zolomatok/Johnny"
    s.license     = { :type => "MIT" }
    s.authors     = { "Zoltán Matók" => "bellamycpt@gmail.com" }

    s.source   = { :git => "https://github.com/zolomatok/Johnny.git", :tag => "3.0.4"}
    s.requires_arc = true
    s.module_name = 'Johnny'
    s.swift_version = '4.0'

    s.osx.deployment_target = "10.10"
    s.ios.deployment_target = "8.0"
    s.tvos.deployment_target = "9.0"
    s.watchos.deployment_target = "2.0"

    s.osx.source_files = 'Johnny/*.swift', 'Johnny/Extensions/common/*.swift', 'Johnny/Extensions/macOS/*.swift'
    s.ios.source_files = 'Johnny/*.swift', 'Johnny/Extensions/*.swift', 'Johnny/Extensions/common/*.swift'
    s.tvos.source_files = 'Johnny/*.swift', 'Johnny/Extensions/*.swift', 'Johnny/Extensions/common/*.swift'
    s.watchos.source_files = 'Johnny/*.swift', 'Johnny/Extensions/common/*.swift', 'Johnny/Extensions/UIColor.swift', 'Johnny/Extensions/UIImage.swift'

    s.osx.frameworks = 'AppKit', 'Foundation'
    s.ios.frameworks = 'UIKit', 'Foundation'
    s.tvos.frameworks = 'UIKit', 'Foundation'
end
