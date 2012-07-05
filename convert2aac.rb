#!/usr/bin/env ruby
# =====================================================================
# This script will take every file in the ARCHIVE_DIR and convert it to 
# AAC in the TARGET_DIR
# =====================================================================

require "fileutils"
require "highline/import"
require "./lib/tagging"

ARCHIVE_DIR = "/tank/audio/Archive"
TARGET_DIR = "/tank/audio/Music"
TMP_FILE = "/tank/audio/Temp/audio.m4a"

ENCODE_CMD = "/tank/audio/Bin/neroAacEnc"

CMD = "wvunpack \"%{input}\" -o - | #{ENCODE_CMD} -q 0.5 -ignorelength -if - -of \"%{output}\""
MEDIA_GID = 2001

def traverse_archive_dir(dir = "")
  Dir.entries("#{ARCHIVE_DIR}#{dir}").sort.each do |entry|
    next_entry = [dir, entry].join('/')

    if File.file?("#{ARCHIVE_DIR}#{next_entry}") && File.extname("#{next_entry}") == ".wv"

      src_meta = read_ape_tags("#{ARCHIVE_DIR}#{next_entry}")

      # Here's a wavpack file, time to convert it!
      target_file = "#{TARGET_DIR}#{File.dirname(next_entry)}/#{File.basename(next_entry, '.wv')}.m4a"
      unless File.exists?(target_file)
        print "#{next_entry}\n"
        if system(CMD % { :input => "#{ARCHIVE_DIR}#{next_entry}".gsub('$', '\$'), :output => TMP_FILE })
          #FileUtils.mv(TMP_FILE, target_file)
          tag_m4a(TMP_FILE, target_file.gsub('$', '\$'), src_meta)
        end
      end
      File.chown(nil, MEDIA_GID, target_file)

    elsif File.directory?("#{ARCHIVE_DIR}#{next_entry}") and entry[0] != '.'
      Dir.mkdir("#{TARGET_DIR}#{next_entry}") unless File.exists?("#{TARGET_DIR}#{next_entry}")
      traverse_archive_dir(next_entry)
      File.chown(nil, MEDIA_GID, "#{TARGET_DIR}#{next_entry}")
    end

  end
end

traverse_archive_dir
