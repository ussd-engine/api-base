require_relative "lib/api_base/version"

Gem::Specification.new do |spec|
  spec.name = "api_base"
  spec.version = ApiBase::VERSION
  spec.authors = ["Stefan Froelich"]
  spec.email = ["sfroelich01@gmail.com"]
  spec.homepage = "https://github.com/ussd-engine/api-base"

  spec.summary = "Building blocks for building API Clients"
  spec.description = spec.summary
  spec.license = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.0.3"
  spec.add_dependency "faraday", ">= 1.0"
  spec.add_dependency "stoplight", ">= 3.0.0"
end
