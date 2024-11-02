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
  response = HTTParty.get(
    "#{BUNNY_API}/videos",
    headers: HEADERS
  )

  if response.success?
    videos = response.parsed_response['items']

    videos.each do |video|
      title = video['title'][0..30] + (video['title'].length > 30 ? "..." : "")
      meta_tags = video['metaTags']&.map { |tag| "#{tag['property']}: #{tag['value']}" }&.join(' | ') || 'No tags'

      puts "\"#{title}\" | #{meta_tags}"
    end
  else
    puts "❌ Failed to fetch videos: #{response.code} - #{response.body}"
    exit 1
  end
rescue Interrupt
  puts "\nExiting..."
  exit 0
rescue StandardError => e
  puts "\n❌ Error: #{e.message}"
  exit 1
end
