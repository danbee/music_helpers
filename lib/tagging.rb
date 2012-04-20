# ======================================================================
# Library to supply some basic tag handling functions
# ======================================================================

# apetag will let us read the tags from the wavpack file.
require "apetag"

def tag_m4a(source, target, tags = {})
  # sort out the track and disc numbers
  #tags["disc"], tags["totaldiscs"] = tags.delete("disc").split("/") unless tags["disc"].nil?
  #tags["track"], tags["totaltracks"] = tags.delete("track").split("/") unless tags["track"].nil?

  tag_cmd = "AtomicParsley \"#{source.gsub('$', '\$')}\" -o \"#{target.gsub('$', '\$')}\" --foobar2000Enema"
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
  result = system(tag_cmd)
  FileUtils.rm(source) if result
  result
end

def read_ape_tags(file)
  tags = {}
  ApeTag.new(file).fields.each { |key, data| tags[key.downcase] = data.first }
  tags
end
