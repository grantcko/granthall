#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'fileutils'
require 'dotenv/load'
require 'open3'

BASE_DIR = ARGV[0] || '/Volumes/TASTY/videos'
BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}"
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json",
  "content-type" => "application/json"
}

def list_videos_in_folder
  puts "📂 Listing videos in folder: #{BASE_DIR}"
  Dir.glob(File.join(BASE_DIR, '*')).sort.each do |folder|
    next unless File.directory?(folder)
    puts " - #{File.basename(folder)}"
  end
end

def wait_for_video_ready(video_id)
  puts "⏳ Waiting for video to be ready..."
  30.times do
    response = HTTParty.get(
      "#{BUNNY_API}/videos/#{video_id}",
      headers: HEADERS
    )
    return true if response.success? && response['status'] >= 3
    sleep 2
  end
  false
end

def upload_with_curl(url, headers, file_path, title)
  puts "📤 Uploading: #{title}"

  curl_command = [
    'curl',
    '-X', 'PUT',
    '-H', "AccessKey: #{headers['AccessKey']}",
    '-H', "Content-Type: #{headers['Content-Type']}",
    '-T', file_path,
    url
  ]

  system(*curl_command)
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

def upload_video(folder_path)
  metadata_file = File.join(folder_path, 'metadata.json')
  video_file = File.join(folder_path, 'video.mp4')
  thumbnail_file = File.join(folder_path, 'thumbnail.png')

  return unless File.exist?(metadata_file) && File.exist?(video_file)

  metadata = JSON.parse(File.read(metadata_file))

  # Create initial video entry
  response = HTTParty.post(
    "#{BUNNY_API}/videos",
    headers: HEADERS,
    body: { title: metadata['title'] }.to_json
  )

  return unless response.success?
  video_id = response['guid']

  # Upload video file
  upload_with_curl(
    "#{BUNNY_API}/videos/#{video_id}",
    HEADERS.merge({ "Content-Type" => "video/mp4" }),
    video_file,
    metadata['title']
  )

  # Wait for video to be ready
  return unless wait_for_video_ready(video_id)

  # Update video metadata
  meta_tags = [
    { property: "description", value: metadata['description'] },
    { property: "created_date", value: metadata['created_at'] },
    { property: "tags", value: metadata['tags'].join(',') }
  ]

  response = HTTParty.post(
    "#{BUNNY_API}/videos/#{video_id}",
    headers: HEADERS,
    body: {
      title: metadata['title'],
      metaTags: meta_tags
    }.to_json
  )
  puts response.success? ? "✅ Metadata updated" : "❌ Metadata update failed: #{response.code} - #{response.body}"

  # Upload thumbnail if exists
  if File.exist?(thumbnail_file)
    puts "🖼️  Uploading thumbnail"
    response = HTTParty.post(
      "#{BUNNY_API}/videos/#{video_id}/thumbnail",
      headers: HEADERS.merge({ "Content-Type" => "image/png" }),
      body: File.binread(thumbnail_file)
    )
    puts response.success? ? "✅ Thumbnail uploaded" : "❌ Thumbnail upload failed: #{response.code}"
  end

  # Display video info
  display_video_info(video_id)

rescue => e
  puts "❌ Error processing #{folder_path}: #{e.message}"
end

# Main execution
puts "🎥 Starting migration to Bunny.net..."

list_videos_in_folder

Dir.glob(File.join(BASE_DIR, '*')).sort.each do |folder|
  next unless File.directory?(folder)
  puts "\n📁 Processing: #{File.basename(folder)}"
  upload_video(folder)
end

puts "\n🎉 Migration complete!"
