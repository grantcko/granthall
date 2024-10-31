#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'dotenv/load'
require 'tty-prompt'

BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}"
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json",
  "content-type" => "application/json"
}

SAMPLE_TAGS = [
  'funny', 'dramatic', 'action', 'tutorial', 'vlog',
  'music', 'gaming', 'cooking', 'travel', 'educational'
]

def prompt_for_video_details
  prompt = TTY::Prompt.new

  video_file = prompt.ask("Enter the path to the video file:")
  thumbnail_file = prompt.ask("Enter the path to the thumbnail file (optional):")
  selected_tags = prompt.multi_select("Select tags for this video (use arrow keys and space to select):", SAMPLE_TAGS)
  upload_date = prompt.ask("Enter the upload date (YYYY-MM-DD):")
  title = prompt.ask("Enter the video title:")
  description = prompt.ask("Enter the video description:")

  {
    video_file: video_file,
    thumbnail_file: thumbnail_file,
    tags: selected_tags.join(','),
    upload_date: upload_date,
    title: title,
    description: description
  }
end

def display_video_details(details)
  puts "\n📽️  Video Details:"
  puts "File: #{details[:video_file]}"
  puts "Thumbnail: #{details[:thumbnail_file]}"
  puts "Tags: #{details[:tags]}"
  puts "Upload Date: #{details[:upload_date]}"
  puts "Title: #{details[:title]}"
  puts "Description: #{details[:description]}"
end

def upload_video(details)
  # Create initial video entry
  response = HTTParty.post(
    "#{BUNNY_API}/videos",
    headers: HEADERS,
    body: { title: details[:title] }.to_json
  )

  unless response.success?
    puts "❌ Failed to create video entry: #{response.code} - #{response.body}"
    return
  end

  video_id = response['guid']

  # Upload video file
  puts "📤 Uploading video file..."
  system('curl', '-X', 'PUT', '-H', "AccessKey: #{HEADERS['AccessKey']}", '-H', "Content-Type: video/mp4", '-T', details[:video_file], "#{BUNNY_API}/videos/#{video_id}")

  # Update video metadata
  meta_tags = [
    { property: "description", value: details[:description] },
    { property: "created_date", value: details[:upload_date] },
    { property: "tags", value: details[:tags] }
  ]

  response = HTTParty.post(
    "#{BUNNY_API}/videos/#{video_id}",
    headers: HEADERS,
    body: {
      title: details[:title],
      metaTags: meta_tags
    }.to_json
  )

  if response.success?
    puts "✅ Metadata updated"
  else
    puts "❌ Metadata update failed: #{response.code} - #{response.body}"
  end

  # Upload thumbnail if exists
  if details[:thumbnail_file] && !details[:thumbnail_file].empty?
    puts "🖼️  Uploading thumbnail..."
    response = HTTParty.post(
      "#{BUNNY_API}/videos/#{video_id}/thumbnail",
      headers: HEADERS.merge({ "Content-Type" => "image/png" }),
      body: File.binread(details[:thumbnail_file])
    )
    puts response.success? ? "✅ Thumbnail uploaded" : "❌ Thumbnail upload failed: #{response.code}"
  end

  # Display video info
  display_video_info(video_id)
end

def display_video_info(video_id)
  response = HTTParty.get(
    "#{BUNNY_API}/videos/#{video_id}",
    headers: HEADERS
  )

  if response.success?
    video = response.parsed_response
    puts "\n📽️  Video Info:"
    puts "Title: #{video['title']}"
    puts "Status: #{video['status']}"
    puts "Length: #{video['length']} seconds"
    puts "Views: #{video['views']}"
    puts "Storage Size: #{video['storageSize']} bytes"
    puts "Meta Tags:"
    video['metaTags']&.each do |tag|
      puts "  #{tag['property']}: #{tag['value']}"
    end
  else
    puts "❌ Failed to fetch video info: #{response.code}"
  end
end

# Main execution
puts "🎥 Video Upload to Bunny.net"

details = prompt_for_video_details
display_video_details(details)

prompt = TTY::Prompt.new
if prompt.yes?("Is the information correct and ready to upload?")
  upload_video(details)
else
  puts "❌ Upload cancelled."
end
