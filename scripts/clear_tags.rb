#!/usr/bin/env ruby

require 'json'

base_path = ARGV[0] || '/Volumes/TASTY/videos'

puts "⚠️  WARNING: This will clear ALL tags from ALL videos!"
print "Are you sure you want to continue? (y/N): "
confirmation = STDIN.gets.chomp.downcase

unless confirmation == 'y'
  puts "❌ Operation cancelled"
  exit 1
end

puts "\n🗑️  Clearing all tags..."

Dir.glob(File.join(base_path, '*')).sort.each do |folder|
  next unless File.directory?(folder)
  metadata_path = File.join(folder, 'metadata.json')
  next unless File.exist?(metadata_path)

  metadata = JSON.parse(File.read(metadata_path))
  metadata['tags'] = []
  File.write(metadata_path, JSON.pretty_generate(metadata))
  puts "✅ Cleared tags for: #{metadata['title']}"
end

puts "\n👋 All tags cleared"
