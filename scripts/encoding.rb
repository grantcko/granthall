#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'dotenv/load'

BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}"
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json"
}

def make_request(endpoint, description)
  puts "\n🔍 Checking #{description}..."
  response = HTTParty.get("#{BUNNY_API}#{endpoint}", headers: HEADERS)

  if response.success?
    puts JSON.pretty_generate(response.parsed_response)
  else
    puts "❌ Failed (#{response.code}): #{response.body}"
  end
  puts "\n---"
end

begin
  # Check basic library info
  make_request("", "Library Info")

  # Check collection settings
  make_request("/settings", "Collection Settings")

  # Check a specific video's encoding info (using the first video we find)
  videos_response = HTTParty.get("#{BUNNY_API}/videos", headers: HEADERS)
  if videos_response.success? && videos_response['items']&.first
    video_id = videos_response['items'].first['guid']
    make_request("/videos/#{video_id}", "Sample Video Settings")
  end

rescue StandardError => e
  puts "\n❌ Error: #{e.message}"
  exit 1
end
