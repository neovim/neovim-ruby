require "rubygems"
require "bundler/setup"
require "rspec/autorun"

require File.expand_path("../support/remote.rb", __FILE__)

RSpec.shared_examples "Remote Neovim process", :remote => true do
  before { Remote.new("/tmp/neovim.sock").restart }
end
