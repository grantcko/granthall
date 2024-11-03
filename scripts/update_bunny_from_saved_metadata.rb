#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'dotenv/load'
require 'fileutils'

BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}"
SAVED_METADATA_DIR = '/Volumes/TASTY/saved_metadata'
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json",
  "content-type" => "application/json"
}

def load_saved_metadata
  metadata_map = {}

  # Look through all numbered folders in saved_metadata
  Dir.glob(File.join(SAVED_METADATA_DIR, '*')).sort.each do |folder|
    metadata_path = File.join(folder, 'metadata.json')
    next unless File.exist?(metadata_path)

    begin
      metadata = JSON.parse(File.read(metadata_path))
      if metadata['title'] && metadata['description']
        metadata_map[metadata['title']] = metadata['description']
        puts "📁 Loaded metadata for: #{metadata['title']}"
      end
    rescue JSON::ParserError => e
      puts "❌ Error parsing #{metadata_path}: #{e.message}"
    end
  end

  metadata_map
end

def update_video_description(video_id, title, description)
  # Get current metaTags
  response = HTTParty.get(
    "#{BUNNY_API}/videos/#{video_id}",
    headers: HEADERS
  )

  if response.success?
    current_meta_tags = response.parsed_response['metaTags'] || []
    current_meta_tags.reject! { |tag| tag['property'] == 'description' }
    current_meta_tags << { property: 'description', value: description }

    update_response = HTTParty.post(
      "#{BUNNY_API}/videos/#{video_id}",
      headers: HEADERS,
      body: {
        title: title,
        metaTags: current_meta_tags
      }.to_json
    )

    if update_response.success?
      puts "✅ Updated description for: #{title}"
      puts "   Description: #{description}"
    else
      puts "❌ Failed to update description: #{update_response.code}"
    end
  else
    puts "❌ Failed to fetch video info: #{response.code}"
  end
end

begin
  puts "📥 Loading saved metadata..."
  saved_metadata = load_saved_metadata
  puts "📚 Loaded #{saved_metadata.size} metadata files"

  puts "\n📥 Fetching videos from Bunny CDN..."
  response = HTTParty.get("#{BUNNY_API}/videos", headers: HEADERS)

  if response.success?
    videos = response.parsed_response['items']
    puts "\n🎥 Found #{videos.size} videos"
    updated_count = 0

    videos.each do |video|
      title = video['title']

      # Skip if video already has a description metaTag
      next if video['metaTags']&.any? { |tag| tag['property'] == 'description' }

      # Skip if we don't have saved metadata for this title
      saved_description = saved_metadata[title]
      next unless saved_description

      puts "\n📝 Processing: #{title}"
      puts "Description from saved metadata: #{saved_description}"
      update_video_description(video['guid'], title, saved_description)
      updated_count += 1
    end

    puts "\n🎉 Update complete!"
    puts "Updated #{updated_count} videos"
  else
    puts "❌ Failed to fetch videos: #{response.code}"
    exit 1
  end
rescue => e
  puts "❌ Error: #{e.message}"
  exit 1
end
