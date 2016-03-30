#!/usr/bin/env ruby
#
# Convert STDIN from JSON to MessagePack.
require "json"
require "msgpack"

ARGF.binmode
print MessagePack.pack(JSON.parse(ARGF.read.strip))
