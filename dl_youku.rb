#!/usr/bin/env ruby

require 'open-uri'
require 'json'
require 'pp'

def getFileIDMixString(seed)
	src = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/\:._-1234567890'
	s = seed
	out = ""
	n = src.length
	1.upto(n){
		s = (s*211+30031) % 65536;
		index = (s * src.length) / 65536;
		out = out + src[index]
		src = src.delete(src[index])
	}
	out
end

def getFileID(fid, seed)
	ids = fid.split('*')
	s = getFileIDMixString(seed)
	out = ""
	ids.map{|e| e.to_i}.each{|i| out=out+s[i]}
	out
end

url=ARGV[0]
fail "invalid url" unless url.split('/').last =~ /id_(\w+)\.html/

vid=$1

content = open('http://v.youku.com/player/getPlayList/VideoIDS/'+vid).read
info = JSON.parse(content)

segs = info['data'].first['segs']
title = info['data'].first['title']

seed = info['data'].first['seed']
#p getFileIDMixString(seed)

#pp segs
FLVPATH='http://f.youku.com/player/getFlvPath/sid/'
USERAGENT='Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)'

dl = "flv"
dl = "hd2" if segs.include? "hd2"

priority={"hd2" => 0, "mp4"=>1, "flv"=>2}
priority.default = 100
segss = segs.sort_by{|k,v| priority[k]}
pp info

puts title
puts ''

`mkdir "#{title}"`
dodl = true
segss.each {|_e|
	k = _e[0]
	v = _e[1]
	puts k
	sfid = info['data'].first['streamfileids'][k]
	fid1=getFileID(sfid, seed)
	`: > "#{title}/list.txt"`
	v.sort{|x,y| x['no'] <=> y['no']}.each_with_index{|e,i|
		flvurl = FLVPATH+"00_#{'%02d' % i}/st/flv/fileid/"+fid1[0..7]+('%02d' %i)+fid1[10..-1]+'?K='+e['k']
		puts flvurl
		`wget -U "#{USERAGENT}" -O "#{title}/#{i}.#{k}" "#{flvurl}"` if dodl
		`echo "file #{i}.#{k}" >> "#{title}/list.txt"`
	}
	puts ''
	dodl = false
}

