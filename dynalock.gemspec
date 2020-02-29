
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dynalock/version"

Gem::Specification.new do |spec|
  spec.name          = "dynalock"
  spec.version       = Dynalock::VERSION
  spec.authors       = ["Guillermo Ávarez"]
  spec.email         = ["guillermo@cientifico.net"]

  spec.summary       = %q{Distributed lock using dynamodb}
  spec.description   = %q{dynalock is a distributed lock that uses Amazon Web Service Dynamod DB}
  spec.homepage      = "https://github.com/tourlane/dynalock"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk-dynamodb"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
