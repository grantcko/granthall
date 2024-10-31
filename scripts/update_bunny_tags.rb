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
  'featured', 'narrative', 'corporate', 'documentary'
]

def display_video_info(video)
  puts "\n📽️  Video Info:"
  puts "Title: #{video['title']}"
  puts "ID: #{video['guid']}"
  puts "Status: #{video['status']}"
  puts "Length: #{video['length']} seconds"
  puts "Views: #{video['views']}"
  puts "Meta Tags:"
  video['metaTags']&.each do |tag|
    puts "  #{tag['property']}: #{tag['value']}"
  end
end

def update_video_tags(video_id, title, selected_tags)
  tags_string = selected_tags.join(',')

  puts "Updating '#{title}' with tags: #{tags_string}"

  # Prepare metaTags array
  meta_tags = [{ property: 'tags', value: tags_string }]

  response = HTTParty.post(
    "#{BUNNY_API}/videos/#{video_id}",
    headers: HEADERS,
    body: {
      title: title,
      metaTags: meta_tags
    }.to_json
  )

  if response.success?
    puts "✅ Updated tags"
  else
    puts "❌ Failed to update tags: #{response.code} - #{response.body}"
  end
end

# Main execution
puts "🎥 Fetching videos from Bunny.net..."

response = HTTParty.get(
  "#{BUNNY_API}/videos",
  headers: HEADERS
)

if response.success?
  videos = response.parsed_response['items']
  puts "Found #{videos.length} videos"

  prompt = TTY::Prompt.new

  videos.each do |video|
    display_video_info(video)

    selected_tags = prompt.multi_select("Select tags for this video (use arrow keys and space to select):", SAMPLE_TAGS)

    if selected_tags.any?
      update_video_tags(video['guid'], video['title'], selected_tags)
    else
      puts "Skipping..."
    end
  end

  puts "\n🎉 Done!"
else
  puts "❌ Failed to fetch videos: #{response.code} - #{response.body}"
end
