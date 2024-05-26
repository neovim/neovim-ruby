@echo off
pushd "%~dp0\.." 2>NUL
ruby -I %CD%\lib %CD%\exe\neovim-ruby-host %*
