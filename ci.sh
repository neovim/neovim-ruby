#!/bin/sh

screen -S neovim -d -m bundle exec rake neovim:start

bundle exec rspec spec
TEST_STATUS=$?

screen -S neovim -X stuff ":q!"

exit $TEST_STATUS
