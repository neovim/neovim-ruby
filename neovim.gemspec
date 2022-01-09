lib = File.expand_path("lib", __dir__)
$:.unshift(lib) unless $:.include?(lib)
require "neovim/version"

Gem::Specification.new do |spec|
  spec.name          = "neovim"
  spec.version       = Neovim::VERSION
  spec.authors       = ["Alex Genco"]
  spec.email         = ["alexgenco@gmail.com"]
  spec.summary       = "A Ruby client for Neovim"
  spec.homepage      = "https://github.com/neovim/neovim-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = "exe"
  spec.executables   = ["neovim-ruby-host"]
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = Gem::Requirement.new(">= 2.2.0")

  spec.add_dependency "msgpack", "~> 1.1"
  spec.add_dependency "multi_json", "~> 1.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "vim-flavor"
end
