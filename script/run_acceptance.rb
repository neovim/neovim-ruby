#!/usr/bin/env ruby

require "fileutils"

ENV.delete("VIM")
ENV.delete("VIMRUNTIME")

acceptance_root = File.expand_path("../spec/acceptance", __dir__)
themis_rtp = File.join(acceptance_root, "runtime")
themis_home = File.join(themis_rtp, "flavors/thinca_vim-themis")
manifest = File.join(themis_rtp, "rplugin_manifest.vim")
vimrc = File.join(themis_rtp, "init.vim")

themis_exe = Gem.win_platform? ?
  File.join(themis_home, "bin/themis.bat") :
  File.join(themis_home, "bin/themis")

env = {
  "NVIM_RPLUGIN_MANIFEST" => manifest,
  "THEMIS_VIM" => ENV.fetch("NVIM_EXECUTABLE", "nvim"),
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
