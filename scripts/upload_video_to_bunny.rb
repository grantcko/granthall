#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'time'
require 'dotenv/load'
require 'tty-prompt'
require 'pathname'

# Reference existing tag constants from your codebase
SAMPLE_TAGS = [
  'featured',
  'corporate',
  'documentary',
  'narrative',
  'music-video'
]

BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}"
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json",
  "content-type" => "application/json"
}

def collect_metadata(video_path)
  prompt = TTY::Prompt.new
  filename = File.basename(video_path)

  puts "\n📝 Collecting metadata for: #{filename}"

  # Get video title
  default_title = File.basename(video_path, File.extname(video_path))
  title = prompt.ask("Enter title:", default: default_title)

  # Get description
  description = prompt.ask("Enter description:")

  # Get creation date
  date = prompt.ask("Enter creation date (YYYY-MM-DD):") do |q|
    q.validate(/^\d{4}-\d{2}-\d{2}$/)
    q.messages[:valid?] = 'Date must be in format YYYY-MM-DD'
  end

  # Select tags
  selected_tags = prompt.multi_select(
    "Select tags:",
    SAMPLE_TAGS
  )

  {
    title: title,
    description: description,
    created_date: "#{date}T12:00:00Z",
    tags: selected_tags
  }
end

def upload_video(video_path, metadata)
  puts "\n🎬 Creating video entry..."

  # Create initial video entry
  response = HTTParty.post(
    "#{BUNNY_API}/videos",
    headers: HEADERS,
    body: {
      title: metadata[:title],
      description: metadata[:description]
    }.to_json
  )

  unless response.success?
    puts "❌ Failed to create video entry: #{response.code} - #{response.body}"
    return
  end

  video_id = response['guid']
  puts "✅ Video entry created with ID: #{video_id}"

  # Upload the video file
  puts "\n📤 Uploading video file..."
  escaped_path = video_path.gsub(/([\[\]\s\(\)'"])/) { |m| "\\#{m}" }

  upload_result = system(
    'curl',
    '-X', 'PUT',
    '-H', "AccessKey: #{HEADERS['AccessKey']}",
    '-H', 'Content-Type: video/mp4',
    '-T', escaped_path,
    "#{BUNNY_API}/videos/#{video_id}"
  )

  unless upload_result
    puts "❌ Failed to upload video file"
    return
  end

  puts "✅ Video file uploaded successfully"

  # Prepare metadata tags
  meta_tags = [
    { property: 'created_date', value: metadata[:created_date] }
  ]

  # Add tags if any were selected
  if metadata[:tags].any?
    meta_tags << { property: 'tags', value: metadata[:tags].join(',') }
  end

  # Update video with metadata
  puts "\n📝 Updating metadata..."
  response = HTTParty.post(
    "#{BUNNY_API}/videos/#{video_id}",
    headers: HEADERS,
    body: {
      title: metadata[:title],
      description: metadata[:description],
      metaTags: meta_tags
    }.to_json
  )

  if response.success?
    puts "✅ Metadata updated successfully"
    puts "\n🎉 Upload complete!"
    puts "Title: #{metadata[:title]}"
    puts "Description: #{metadata[:description]}"
    puts "Created Date: #{metadata[:created_date]}"
    puts "Tags: #{metadata[:tags].join(', ')}"
  else
    puts "❌ Failed to update metadata: #{response.code} - #{response.body}"
  end
end

# Main execution
if ARGV.empty?
  puts "❌ Usage: #{$0} <path_to_video_file>"
  exit 1
end

video_path = ARGV[0]
unless File.exist?(video_path)
  puts "❌ Video file not found: #{video_path}"
  exit 1
end

begin
  metadata = collect_metadata(video_path)
  upload_video(video_path, metadata)
rescue Interrupt
  puts "\n\n👋 Upload cancelled"
  exit 1
rescue StandardError => e
  puts "\n❌ Error: #{e.message}"
  exit 1
end
