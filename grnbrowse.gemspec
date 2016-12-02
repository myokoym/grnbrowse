lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grnbrowse/version'

Gem::Specification.new do |spec|
  spec.name          = "grnbrowse"
  spec.version       = Grnbrowse::VERSION
  spec.authors       = ["Masafumi Yokoyama"]
  spec.email         = ["myokoym@gmail.com"]
  spec.summary       = %q{Make browsing easy for Groonga's database.}
  spec.description   = spec.summary
  spec.homepage      = "http://myokoym.net/grnbrowse/"
  spec.license       = "LGPLv2.1+"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("rroonga", ">= 5.0.0")
  spec.add_runtime_dependency("thor")
  spec.add_runtime_dependency("sinatra")
  spec.add_runtime_dependency("sinatra-contrib")
  spec.add_runtime_dependency("sinatra-cross_origin")
  spec.add_runtime_dependency("padrino-helpers")
  spec.add_runtime_dependency("kaminari")
  spec.add_runtime_dependency("haml")
  spec.add_runtime_dependency("launchy")

  spec.add_development_dependency("bundler")
  spec.add_development_dependency("rake")
end
