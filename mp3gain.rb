#!/usr/bin/env ruby
require "fileutils"
require "highline/import"

music_dir = "/pub/media/audio/Music"

cmd = "mp3gain -T -a -c -d +3.0 \"%s\"/*.mp3"

def traverse_music_dir(dir, cmd)
  if Dir.entries(dir).find { |e| e[-3,3] == 'mp3' }
    unless File.exists?("#{dir}/mp3gain")
      print "Ungained MP3's found, running MP3Gain on #{dir}\n"
      if system(cmd % dir)
        FileUtils.touch "#{dir}/mp3gain"
      else
        unless agree("mp3gain exited with an error, do you want to continue?")
          exit
        end
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
