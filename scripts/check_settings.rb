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

  # Check a specific video's encoding info using the provided video ID
  if ARGV.empty?
    puts "❌ Please provide a video ID as an argument."
    exit 1
  end

  video_id = ARGV[0]
  make_request("/videos/#{video_id}", "Video Settings for ID: #{video_id}")

rescue StandardError => e
  puts "\n❌ Error: #{e.message}"
  exit 1
end
