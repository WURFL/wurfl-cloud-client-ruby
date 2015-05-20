# -*- encoding: utf-8 -*-
#
# Copyright (c) 2015 ScientiaMobile Inc.
#
# The WURFL Cloud Client is intended to be used in both open-source and
# commercial environments. To allow its use in as many situations as possible,
# the WURFL Cloud Client is dual-licensed. You may choose to use the WURFL
# Cloud Client under either the GNU GENERAL PUBLIC LICENSE, Version 2.0, or
# the MIT License.
#
# Refer to the COPYING.txt file distributed with this package.
#
$:.push File.expand_path("../lib", __FILE__)
require "wurfl_cloud/version"

Gem::Specification.new do |s|
  s.name        = "wurfl_cloud_client"
  s.version     = WurflCloud::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["ScientiaMobile, Inc."]
  s.email       = ["support@scientiamobile.com"]
  s.homepage    = ""
  s.summary     = %q{Wurfl Cound Ruby Client}
  s.description = %q{ruby client for the Wurfl Cloud API}

  s.rubyforge_project = "wurfl_cloud_client"
  
  s.add_dependency "json"
  s.add_dependency "rack"
  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"
  s.add_development_dependency "simplecov"
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
