#!/usr/bin/env ruby
require "fileutils"
require "highline/import"

music_dir = "/Users/danbarber/Music/Archive"

cmd = "wvgain -an \"%s\"/*.wv"

def traverse_music_dir(dir, cmd)
  if Dir.entries(dir).detect { |e| e.end_with?("wv") }
    unless File.exists?("#{dir}/.replaygain")
      print "Ungained tracks found, running wvgain on #{dir}\n"

      if system(cmd % dir)
        FileUtils.touch "#{dir}/.replaygain"
      else
        exit
      end
    end
  end

  Dir.entries(dir).each do |entry|
    # print entry + "\n"
    next_entry = [dir, entry].join('/')
    traverse_music_dir(next_entry, cmd) if File.directory?(next_entry) and entry[0] != '.'
  end
end

traverse_music_dir(music_dir, cmd)
