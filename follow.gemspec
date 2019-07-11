
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "follow/version"

Gem::Specification.new do |spec|
  spec.name          = "follow"
  spec.version       = Follow::VERSION
  spec.authors       = ["Fletcher Wilkens"]
  spec.email         = ["fletcher.wilkens1@gmail.com"]

  spec.summary       = "Follow rubygems as new gems are published."
  spec.homepage      = "https://github.com/fwilkens/follow"
  spec.metadata      = { "source_code_uri" => "https://github.com/fwilkens/follow" }

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "timecop", "~> 0.9"
  spec.add_development_dependency "vcr", "~> 5.0"
  spec.add_development_dependency "webmock", "~> 3.6"
end
