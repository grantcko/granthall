#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'dotenv/load'

BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}"
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json"
}

begin
  puts "📥 Fetching videos from Bunny CDN..."
  response = HTTParty.get("#{BUNNY_API}/videos", headers: HEADERS)

  if response.success?
    videos = response.parsed_response['items']
    puts "\n🎥 Found #{videos.size} videos\n"

    # Sort videos by title
    sorted_videos = videos.sort_by { |video| video['title'].downcase }

    # Get the longest title for padding
    max_length = sorted_videos.map { |v| v['title'].length }.max

    # Print each video with its details
    sorted_videos.each_with_index do |video, index|
      title = video['title']
      description = video['metaTags']&.find { |tag| tag['property'] == 'description' }&.dig('value')
      description = description ? description[0..50] + (description.length > 50 ? '...' : '') : 'No description'

      puts "#{(index + 1).to_s.rjust(2)}. #{title.ljust(max_length)} | #{description}"
    end

  else
    puts "❌ Failed to fetch videos: #{response.code}"
    exit 1
  end
rescue => e
  puts "❌ Error: #{e.message}"
  exit 1
end
