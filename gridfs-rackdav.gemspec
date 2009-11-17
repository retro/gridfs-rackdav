# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gridfs-rackdav}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mihael Konjevi\304\207"]
  s.date = %q{2009-11-17}
  s.description = %q{gridfs-rackdav enables you to use GridFS as backend for WebDAV collections with RackDAV application}
  s.email = %q{konjevic@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.md"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.md",
     "Rakefile",
     "VERSION",
     "gridfs-rackdav.gemspec",
     "lib/gridfs-rackdav.rb",
     "lib/gridfs-rackdav/gridfs_model.rb",
     "lib/gridfs-rackdav/gridfs_resource.rb",
     "spec/gridfs-rackdav_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/retro/gridfs-rackdav}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{GridFS resource adapter for RackDAV}
  s.test_files = [
    "spec/gridfs-rackdav_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_runtime_dependency(%q<georgi-rack_dav>, [">= 0.1.1"])
      s.add_runtime_dependency(%q<mongodb-mongo>, [">= 0.1"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<georgi-rack_dav>, [">= 0.1.1"])
      s.add_dependency(%q<mongodb-mongo>, [">= 0.1"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<georgi-rack_dav>, [">= 0.1.1"])
    s.add_dependency(%q<mongodb-mongo>, [">= 0.1"])
  end
end
