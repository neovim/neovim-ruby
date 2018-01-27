#!/usr/bin/env ruby

require "fileutils"

ENV.delete("VIM")
ENV.delete("VIMRUNTIME")

acceptance_root = File.expand_path("../../spec/acceptance", __FILE__)
manifest = File.join(acceptance_root, "runtime/rplugin.vim")
vimrc = File.join(acceptance_root, "runtime/init.vim")

FileUtils.rm_f(manifest)

themis_exe = Gem.win_platform? ?
  "vendor/vim-themis/bin/themis.bat" :
  "vendor/vim-themis/bin/themis"

Dir.chdir(acceptance_root) do
  env = {
    "NVIM_RPLUGIN_MANIFEST" => manifest,
    "THEMIS_VIM" => "nvim",
    "THEMIS_HOME" => "vendor/vim-themis",
    "THEMIS_ARGS" => "-e -s --headless -u #{vimrc}"
  }

  system(
    env,
    "nvim",
    "-e", "-s", "--headless",
    "-u", vimrc,
    "+UpdateRemotePlugins", "+qa!"
  )

  exec(
    env,
    themis_exe,
    "--runtimepath", "runtime",
    "--reporter", "dot",
    "."
  )
end
