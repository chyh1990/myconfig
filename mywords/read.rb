#!/usr/bin/env ruby
# encoding: utf-8

debug=false
if ARGV[0] == "-d"
	debug = true
	ARGV.shift
end

idx = File.read(ARGV[0]).unpack("a4i*")
STDERR.puts "#{idx.length}\t#{idx[0]}" if debug
fail "MAGIC ERROR" unless idx[0].eql? "INDX"
item = rand idx.length-1
off = idx[item]
STDERR.puts "choose #{item}: #{off}" if debug
File.open(ARGV[1]) do |f|
	f.seek off
	puts f.readline
end
