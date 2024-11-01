#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'dotenv/load'

BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}/videos"
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json",
  "content-type" => "application/json"
}

def get_video_data(title)
  response = HTTParty.get(BUNNY_API, headers: HEADERS)
  return nil unless response.success?

  response.parsed_response['items'].find { |v| v['title'] == title }
end

def update_video(video_id, title, meta_tags)
  response = HTTParty.post(
    "#{BUNNY_API}/#{video_id}",
    headers: HEADERS,
    body: {
      title: title,
      metaTags: meta_tags
    }.to_json
  )

  if response.success?
    puts "✅ Updated #{title}"
  else
    puts "❌ Failed to update #{title}: #{response.code}"
  end
end

# Get both videos
video1 = get_video_data("STA Auction circa 2020")
video2 = get_video_data("STA Auction 2022")

unless video1 && video2
  puts "❌ Couldn't find one or both videos"
  exit 1
end

# Store original data
video1_meta = video1['metaTags']
video1_title = video1['title']
video2_meta = video2['metaTags']
video2_title = video2['title']

puts "\n🔄 Swapping video metadata..."

# Swap the data
update_video(video1['guid'], video2_title, video2_meta)
update_video(video2['guid'], video1_title, video1_meta)

puts "\n✨ Swap complete!"
