# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "middleman-sri_calculator"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Angus McIntyre"]
  s.email       = ["http://nomadcode.com/contact/"]
  s.homepage    = "http://nomadcode.com"
  s.summary     = %q{Middleman extension to perform subresource integrity calculations}
  s.description = %q{A Middleman extension to compute subresource integrity hashes for web resources such as JS or CSS.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  # The version of middleman-core your extension depends on
  s.add_runtime_dependency("middleman-core", [">= 4.2.1"])
  
  # Additional dependencies
  # s.add_runtime_dependency("gem-name", "gem-version")
end
