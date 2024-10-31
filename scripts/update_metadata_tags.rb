#!/usr/bin/env ruby

require 'json'
require 'tty-prompt'
require 'pathname'

# Predefined tags that can be selected with arrow keys
COMMON_TAGS = [
  'skip',
  'featured',
  'client-work',
  'music-video',
  'narrative',
  'documentary',
]

def save_metadata(metadata_path, metadata)
  File.write(metadata_path, JSON.pretty_generate(metadata))
  puts "\n💾 Saved changes to #{metadata_path}"
rescue => e
  puts "❌ Error saving metadata: #{e.message}"
end

def update_metadata_tags(folder_path)
  metadata_path = File.join(folder_path, 'metadata.json')
  return unless File.exist?(metadata_path)

  metadata = JSON.parse(File.read(metadata_path))
  current_tags = metadata['tags'] || []
  folder_name = File.basename(folder_path)

  puts "\n================================================"
  puts "📁 Processing folder: #{folder_name}"
  puts "📝 Video title: #{metadata['title']}"
  puts "🏷️  Current tags: #{current_tags.empty? ? 'None' : current_tags.join(', ')}"

  prompt = TTY::Prompt.new

  selected_tag = prompt.select(
    "Select a tag (or 'skip' to move to next video):",
    COMMON_TAGS,
    cycle: true
  )

  return if selected_tag == 'skip'

  if !current_tags.include?(selected_tag)
    metadata['tags'] = (current_tags + [selected_tag]).uniq
    save_metadata(metadata_path, metadata)
    puts "✅ Added tag: #{selected_tag}"
  else
    if prompt.yes?("Remove tag '#{selected_tag}'?")
      metadata['tags'] = current_tags - [selected_tag]
      save_metadata(metadata_path, metadata)
      puts "✅ Removed tag: #{selected_tag}"
    end
  end

rescue JSON::ParserError => e
  puts "❌ Error parsing metadata.json in #{folder_path}: #{e.message}"
end

# Main execution
if ARGV.empty?
  puts "❌ Usage: #{$0} <path_to_video_folders>"
  exit 1
end

base_path = ARGV[0]
unless Dir.exist?(base_path)
  puts "❌ Directory not found: #{base_path}"
  exit 1
end

puts "\n🏷️  Metadata Tags Update Tool"
puts "=========================="
puts "Base directory: #{base_path}"
puts "Press Ctrl+C at any time to exit"

begin
  Dir.glob(File.join(base_path, '*')).sort.each do |folder|
    next unless File.directory?(folder)
    update_metadata_tags(folder)
  end
rescue Interrupt
  puts "\n\n👋 Exiting - all changes have been saved"
  exit 0
end

puts "\n🎉 Tag updates complete!"
