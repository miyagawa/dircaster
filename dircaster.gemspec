# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dircaster/version'

Gem::Specification.new do |gem|
  gem.name          = "dircaster"
  gem.version       = Dircaster::VERSION
  gem.authors       = ["Tatsuhiko Miyagawa"]
  gem.email         = ["miyagawa@bulknews.net"]
  gem.description   = %q{directory podcaster}
  gem.summary       = %q{Generate RSS 2.0 Podcast out of a directory with *.mp3 files}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
