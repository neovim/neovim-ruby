#!/usr/bin/env ruby

$:.unshift File.expand_path("../lib", __dir__)

require "neovim"
require "pathname"

nvim_docs = []
buffer_docs = []
window_docs = []
tabpage_docs = []
nvim_exe = ENV.fetch("NVIM_EXECUTABLE", "nvim")
nvim_vrs = %x(#{nvim_exe} --version).split("\n").first

event_loop = Neovim::EventLoop.child([nvim_exe, "-u", "NONE", "-n"])
session = Neovim::Session.new(event_loop)
nvim_defs = Neovim::Client.instance_methods(false)
buffer_defs = Neovim::Buffer.instance_methods(false)
tabpage_defs = Neovim::Tabpage.instance_methods(false)
window_defs = Neovim::Window.instance_methods(false)

session.request(:nvim_get_api_info)[1]["functions"].each do |func|
  func_name = func["name"]
  params = func["parameters"]

  case func_name
  when /^nvim_buf_(.+)/
    method_name = $1
    params.shift
    next if buffer_defs.include?(method_name.to_sym)
  when /^nvim_win_(.+)/
    method_name = $1
    params.shift
    next if window_defs.include?(method_name.to_sym)
  when /^nvim_tabpage_(.+)/
    method_name = $1
    params.shift
    next if tabpage_defs.include?(method_name.to_sym)
  when /^nvim_(.+)/
    method_name = $1
    next if nvim_defs.include?(method_name.to_sym)
  else
    next
  end

  return_type = func["return_type"]
  param_names = params.map(&:last)
  param_str = params.empty? ? "" : "(#{param_names.join(", ")})"
  method_decl = "@method #{method_name}#{param_str}"
  method_desc = "  See +:h #{func_name}()+"
  param_docs = params.map do |type, name|
    "  @param [#{type}] #{name}"
  end
  return_doc = "  @return [#{return_type}]\n"
  method_doc = [method_decl, method_desc, *param_docs, return_doc].join("\n")
  method_doc.gsub!(/ArrayOf\((\w+)[^)]*\)/, 'Array<\1>')
  method_doc.gsub!(/Dictionary/, "Hash")

  case func_name
  when /nvim_buf_(.+)/
    buffer_docs << method_doc
  when /nvim_win_(.+)/
    window_docs << method_doc
  when /nvim_tabpage_(.+)/
    tabpage_docs << method_doc
  when /nvim_(.+)/
    nvim_docs << method_doc
  else
    raise "Unexpected function #{func_name.inspect}"
  end
end

lib_dir = Pathname.new(File.expand_path("../lib/neovim", __dir__))

{
  "client.rb" => nvim_docs,
  "buffer.rb" => buffer_docs,
  "tabpage.rb" => tabpage_docs,
  "window.rb" => window_docs,
}.each do |filename, docs|
  path = lib_dir.join(filename)
  contents = File.read(path)
  doc_str = ["=begin", *docs, "=end"].join("\n")

  contents.sub!(/=begin.+=end/m, doc_str)
  contents.sub!(
    /# The methods documented here were generated using .+$/,
    "# The methods documented here were generated using #{nvim_vrs}"
  )

  File.write(path, contents)
end
