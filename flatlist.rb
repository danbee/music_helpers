#!/usr/bin/env ruby
require "fileutils"
require "highline/import"

dir = $1 || "."

def traverse_dir(dir)
  print "#{dir}\n"
  Dir.entries(dir).sort.each do |entry|
    # print entry + "\n"
    next_entry = [dir, entry].join('/')
    traverse_dir(next_entry) if File.directory?(next_entry) and entry[0] != '.'
  end
end

print "#{dir}\n"

traverse_dir(dir)
