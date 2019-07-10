#!/usr/bin/env ruby

$:.unshift File.expand_path("../lib", __dir__)

require "neovim"
require "json"
require "pp"

nvim_exe = ENV.fetch("NVIM_EXECUTABLE", "nvim")
event_loop = Neovim::EventLoop.child([nvim_exe, "-u", "NONE", "-n"])
session = Neovim::Session.new(event_loop)
puts JSON.pretty_generate(session.request(:nvim_get_api_info))
