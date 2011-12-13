# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "ragelink"
  s.version     = "0.0.7"
  s.authors     = ["Shajith Chacko"]
  s.email       = ["shajith@zendesk.com"]
  s.homepage    = ""
  s.summary     = %q{Autolink via Ragel}
  s.description = %q{Autolink via Ragel}

  s.rubyforge_project = "ragelink"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.extensions    << "lib/ragelink/ext/extconf.rb"
  # specify any dependencies here; for example:
  s.add_development_dependency "rake-compiler"
  s.add_development_dependency "minitest"
end
