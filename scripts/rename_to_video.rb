#!/usr/bin/env ruby

require 'fileutils'

BASE_DIR = ARGV[0] || '/Volumes/TASTY/videos'

puts "🔍 Finding all 'original.mp4' files in #{BASE_DIR}..."

# Use find command to locate all original.mp4 files
files = `find "#{BASE_DIR}" -name "original.mp4"`.split("\n")

if files.empty?
  puts "✨ No 'original.mp4' files found"
  exit
end

puts "\nFound #{files.length} files to rename:"
files.each do |file|
  new_name = file.gsub('original.mp4', 'video.mp4')
  puts "  #{File.basename(file)} -> #{File.basename(new_name)}"
end

print "\nProceed with renaming? (y/N): "
confirm = STDIN.gets.chomp.downcase

if confirm == 'y'
  files.each do |file|
    new_name = file.gsub('original.mp4', 'video.mp4')
    FileUtils.mv(file, new_name)
    puts "✅ Renamed: #{File.basename(file)}"
  end
  puts "\n🎉 All files renamed successfully!"
else
  puts "\n❌ Operation cancelled"
end
