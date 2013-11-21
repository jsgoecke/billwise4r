# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "billwise4r/version"

Gem::Specification.new do |s|
  s.name                   =  "billwise4r"
  s.version                =  Billwise4r::VERSION
  s.authors                =  ["Jason Goecke","John Dyer"]
  s.email                  =  ["jason@goecke.net","johntdyer@gmail.com"]
  s.homepage               =  %q{http://github.com/jsgoecke/billwise4r}
  s.summary                =  %q{Ruby lib for consuming the Billwise SOAP/XML API}
  s.description            =  %q{Ruby lib for consuming the Billwise SOAP/XML API}
  s.rubygems_version       =  %q{1.5.0}
  s.required_ruby_version  =  '>= 1.9'
  s.licenses               = ['MIT']
  s.summary                =  %q{Ruby lib for consuming the Billwise SOAP/XML API}
  s.test_files             =  [
    "spec/billwise4r_spec.rb",
    "spec/spec_helper.rb",
    "spec/connect_sm_service.wsdl",
    "spec/config/config.yml"
  ]

  s.rubyforge_project      =  "billwise4r"

  s.files                  =  `git ls-files`.split("\n")
  s.test_files             =  `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables            =  `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths          =  ["lib","spec"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "awesome_print"
  s.add_runtime_dependency "savon", "~> 0.9.5"
  s.add_runtime_dependency "multi_xml", "= 0.2.2"
end
