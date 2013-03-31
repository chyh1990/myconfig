#!/usr/bin/env ruby
# encoding: utf-8

puts "indexing #{ARGV[0]}"
fail "usage:" unless File.file? ARGV[0]
out = File.open("all.index", "wb")
out.write ["INDX"].pack("a4")

idx = [0]
n = 0
File.open(ARGV[0]) do |f|
	f.each_line do |l|
		n += l.bytesize
		idx.push n
	end
end

out.write idx.pack("i*")
puts idx.length - 1

out.close
