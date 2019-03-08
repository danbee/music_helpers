#!/usr/bin/env ruby
require "fileutils"
require "highline/import"

music_dir = "/Users/danbarber/Music/Library"

cmd = "aacgain -T -a -c \"%s\"/*.{m4a,mp3}"

def traverse_music_dir(dir, cmd)
  if Dir.entries(dir).detect { |e| e.end_with?("m4a", "mp3") }
    unless File.exists?("#{dir}/.replaygain")
      print "Ungained tracks found, running aacgain on #{dir}\n"

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
