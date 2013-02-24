lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'teien/version'

Gem::Specification.new do |gem|
  gem.name          = "teien"
  gem.version       = Teien::VERSION
  gem.authors       = ["abexsoft works"]
  gem.email         = ["abexsoft@gmail.com"]
  gem.description   = %q{An easy 3D world maker.}
  gem.summary       = %q{An easy 3D world maker. You can create your 3D world connected by network with ruby scripts.}
  gem.homepage      = "https://github.com/abexsoft/teien"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'eventmachine'
  gem.add_dependency 'ruby-ois'
  gem.add_dependency 'ruby-ogre'
  gem.add_dependency 'ruby-procedural'
  gem.add_dependency 'ruby-bullet'
  gem.add_dependency 'teienlib'
end
