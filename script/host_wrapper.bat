pushd "%~dp0\.." 2>NUL
ruby -I .\lib .\exe\neovim-ruby-host %*
