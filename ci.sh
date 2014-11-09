#!/bin/sh

bundle exec rake neovim:install

screen -S neovim -d -m bundle exec rake neovim:start

bundle exec rspec spec
TEST_STATUS=$?

screen -X -S neovim quit

exit $TEST_STATUS
