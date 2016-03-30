#!/usr/bin/env ruby
#
# Convert STDIN from MessagePack to JSON
require "json"
require "msgpack"

ARGF.binmode
MessagePack::Unpacker.new(ARGF).each { |data| print JSON.dump(data) }
