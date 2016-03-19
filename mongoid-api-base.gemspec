# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mongoid-api-base/version"
require "date"

Gem::Specification.new do |s|
  s.name             = "mongoid-api-base"
  s.summary          = "Rails concern to implement API controllers for Mongoid models."
  s.homepage         = "http://github.com/slate-studio/mongoid-api-base"
  s.authors          = [ "Alexander Kravets" ]
  s.email            = "alex@slatestudio.com"
  s.date             = Date.today.strftime("%Y-%m-%d")
  s.extra_rdoc_files = %w[ README.md ]
  s.license          = "MIT"
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths    = [ "lib" ]
  s.version          = MongoidApiBase::VERSION
  s.platform         = Gem::Platform::RUBY

  # Ruby ODM framework for MongoDB
  s.add_dependency 'mongoid', '~> 5.0'
  # Clean, powerful, customizable and sophisticated paginator
  s.add_dependency 'kaminari'
  # DSL for pure Ruby code blocks that can be turned into JSON
  s.add_dependency 'swagger-blocks'
  # Clean, powerful, customizable and sophisticated paginator
  s.add_dependency 'kaminari'
end
