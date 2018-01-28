#!/usr/bin/env ruby

require "fileutils"

ENV.delete("VIM")
ENV.delete("VIMRUNTIME")

acceptance_root = File.expand_path("../../spec/acceptance", __FILE__)
themis_home = File.join(acceptance_root, "vendor/vim-themis")
themis_rtp = File.join(acceptance_root, "runtime")
manifest = File.join(acceptance_root, "runtime/rplugin.vim")
vimrc = File.join(acceptance_root, "runtime/init.vim")

themis_exe = Gem.win_platform? ?
  File.join(acceptance_root, "vendor/vim-themis/bin/themis.bat") :
  File.join(acceptance_root, "vendor/vim-themis/bin/themis")

env = {
  "NVIM_RPLUGIN_MANIFEST" => manifest,
  "THEMIS_VIM" => "nvim",
  "THEMIS_HOME" => themis_home,
  "THEMIS_ARGS" => "-e -s --headless -u #{vimrc}"
}

FileUtils.rm_f(manifest)

system(
  env,
  "nvim",
  "-e", "-s", "--headless",
  "-u", vimrc,
  "+UpdateRemotePlugins", "+qa!"
)

exec(env, themis_exe, *ARGV)
