#!/bin/sh

bundle exec rake neovim:install

screen -S neovim -d -m bundle exec rake neovim:start

bundle exec rspec spec
TEST_STATUS=$?

# This doesnt work for some reason
# screen -S neovim -X process ":qa!"

exit $TEST_STATUS
