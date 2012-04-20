#!/usr/bin/env ruby
# =====================================================================
# This script will take every file in the ARCHIVE_DIR and convert it to 
# AAC in the TARGET_DIR
# =====================================================================

require "fileutils"
require "highline/import"
require "./lib/tagging"

ARCHIVE_DIR = "/pub/audio/Archive"
TARGET_DIR = "/pub/audio/Music"
TMP_FILE = "/pub/audio/Temp/tagged.m4a"

MEDIA_GID = 1003

def traverse_archive_dir(dir = "")
  Dir.entries("#{ARCHIVE_DIR}#{dir}").sort.each do |entry|
    next_entry = [dir, entry].join('/')

    if File.file?("#{ARCHIVE_DIR}#{next_entry}") && File.extname("#{next_entry}") == ".wv"

      src_meta = read_ape_tags("#{ARCHIVE_DIR}#{next_entry}")

      # Here's a wavpack file, time to convert it!
      target_file = "#{TARGET_DIR}#{File.dirname(next_entry)}/#{File.basename(next_entry, '.wv')}.m4a"
      print "#{next_entry}\n"
      if tag_m4a(target_file, TMP_FILE, src_meta)
        FileUtils.mv TMP_FILE ,target_file
        File.chown(nil, MEDIA_GID, target_file)
      end

    elsif File.directory?("#{ARCHIVE_DIR}#{next_entry}") and entry[0] != '.'
      Dir.mkdir("#{TARGET_DIR}#{next_entry}") unless File.exists?("#{TARGET_DIR}#{next_entry}")
      traverse_archive_dir(next_entry)
      File.chown(nil, MEDIA_GID, "#{TARGET_DIR}#{next_entry}")
    end

  end
end

traverse_archive_dir
