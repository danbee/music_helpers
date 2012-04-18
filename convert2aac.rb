#!/usr/bin/env ruby
# =====================================================================
# This script will take every file in the ARCHIVE_DIR and convert it to 
# AAC in the TARGET_DIR
# =====================================================================

require "fileutils"
require "highline/import"
# apetag will let us read the tags from the wavpack file.
require "apetag"

ARCHIVE_DIR = "/pub/audio/Archive"
TARGET_DIR = "/pub/audio/Music"
TMP_FILE = "/pub/audio/Temp/audio.m4a"

CMD = "wvunpack \"%{input}\" -o - | neroAacEnc -q 0.5 -ignorelength -if - -of \"%{output}\""
MEDIA_GID = 1003

def tag_file(source, target, tags = {})
  # sort out the track and disc numbers
  #tags["disc"], tags["totaldiscs"] = tags.delete("disc").split("/") unless tags["disc"].nil?
  #tags["track"], tags["totaltracks"] = tags.delete("track").split("/") unless tags["track"].nil?

  tag_cmd = "AtomicParsley \"#{source}\" -o \"#{target}\" --foobar2000Enema"
  tag_cmd += " --artist \"#{tags["artist"].gsub('"', '\"')}\""
  tag_cmd += " --albumArtist \"#{tags["album artist"].gsub('"', '\"') unless tags["album artist"].nil?}\""
  tag_cmd += " --title \"#{tags["title"].gsub('"', '\"')}\""
  tag_cmd += " --album \"#{tags["album"].gsub('"', '\"')}\""
  tag_cmd += " --genre \"#{tags["genre"].gsub('"', '\"') unless tags["genre"].nil?}\""
  tag_cmd += " --tracknum #{tags["track"]}" unless tags["track"].nil?
  tag_cmd += " --disk #{tags["disc"]}" unless tags["disc"].nil?
  tag_cmd += " --year \"#{tags["year"]}\""
  tag_cmd += " --compilation #{tags["itunescompilation"] == "yes"}"
  tag_cmd += " --sortOrder \"album\" \"(#{tags["year"]}) #{tags["album"].gsub('"', '\"')}\""
  print "#{tag_cmd}\n"
  system(tag_cmd)
  FileUtils.rm(source)
end

def traverse_archive_dir(dir = "")
  Dir.entries("#{ARCHIVE_DIR}#{dir}").sort.each do |entry|
    next_entry = [dir, entry].join('/')

    if File.file?("#{ARCHIVE_DIR}#{next_entry}") && File.extname("#{next_entry}") == ".wv"

      # sort out the meta data. Need to handle disc and track numbers specially.
      src_meta = {}
      ApeTag.new("#{ARCHIVE_DIR}#{next_entry}").fields.each { |key, data| src_meta[key.downcase] = data.first }

      # Here's a wavpack file, time to convert it!
      target_file = "#{TARGET_DIR}#{File.dirname(next_entry)}/#{File.basename(next_entry, '.wv')}.m4a"
      unless File.exists?(target_file)
        print "#{next_entry}\n"
        if system(CMD % { :input => "#{ARCHIVE_DIR}#{next_entry}".gsub('$', '\$'), :output => TMP_FILE })
          #FileUtils.mv(TMP_FILE, target_file)
          tag_file(TMP_FILE, target_file.gsub('$', '\$'), src_meta)
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
