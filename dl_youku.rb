#!/usr/bin/env ruby

################################################
#  Author: Yuheng Chen (chyh1990@gmail.com)    #
#  Date:   2014/2                              #
################################################


require 'open-uri'
require 'json'
require 'pp'
require 'optparse'

options = {}
option_parse = OptionParser.new do |opts|
	opts.banner == "Here is the help message of this command line tool"
	options[:merge] = false
	opts.on('-m', '--merge', 'Merge all the video clips') do 
		options[:merge] = true
	end
	opts.on('-t TYPE', '--type TYPE', 'Choose the downloaded (hd2,mp4,flv)') do |val|
		options[:type] = val
	end
end.parse!

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
video_list = []
segss.each {|_e|
	k = _e[0]
	v = _e[1]
	next if k != options[:type]
	sfid = info['data'].first['streamfileids'][k]
	fid1=getFileID(sfid, seed)
	`: > "#{title}/list.txt"`
	v.sort{|x,y| x['no'] <=> y['no']}.each_with_index{|e,i|
		flvurl = FLVPATH+"00_#{'%02d' % i}/st/flv/fileid/"+fid1[0..7]+('%02d' %i)+fid1[10..-1]+'?K='+e['k']
		puts flvurl
		ext = k
		ext = "mp4" if ext == 'hd2'
		if dodl 
			`wget -U "#{USERAGENT}" -O "#{title}/#{i}.#{ext}" "#{flvurl}"`
			`echo "file #{i}.#{k}" >> "#{title}/list.txt"` 
			video_list << "#{title}/#{i}.#{ext}" 
		end
	}
	puts ''
	dodl = false
}
first_input = ""
if  options[:merge]
	video_list.each_with_index do |file, i|
		if i + 1 == video_list.length
			`mv \"#{first_input}\" \"#{title}/output.mp4\"`
			break
		end
		first_input = file if first_input.length == 0
		fn = "#{title}/tmp_#{i}.mp4"
		`mencoder -oac mp3lame -ovc copy -idx -o \"#{fn}\" \"#{first_input}\" \"#{video_list[i + 1]}\"`
		`rm #{first_input}` if i != 0
		first_input = fn
	end
end
