#!/usr/bin/env ruby

require "fileutils"

ENV.delete("VIM")
ENV.delete("VIMRUNTIME")

root = File.expand_path("..", __dir__)
acceptance_root = File.join(root, "spec/acceptance")
themis_rtp = File.join(acceptance_root, "runtime")
themis_home = File.join(themis_rtp, "pack/flavors/start/thinca_vim-themis")
manifest = File.join(themis_rtp, "rplugin_manifest.vim")
vimrc = File.join(themis_rtp, "init.vim")
nvim = ENV.fetch("NVIM_EXECUTABLE", "nvim")

themis_exe = Gem.win_platform? ?
  File.join(themis_home, "bin/themis.bat") :
  File.join(themis_home, "bin/themis")

env = {
  "NVIM_RPLUGIN_MANIFEST" => manifest,
  "THEMIS_VIM" => nvim,
  "THEMIS_HOME" => themis_home,
  "THEMIS_ARGS" => "-e -s --headless -u #{vimrc}"
}

FileUtils.rm_f(manifest)

Dir.chdir(root) do
  system(
    env,
    nvim,
    "-e", "-s", "--headless",
    "-u", vimrc,
    "+UpdateRemotePlugins", "+qa!"
  )

  exec(env, themis_exe, *ARGV)
end
