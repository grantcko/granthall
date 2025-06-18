#!/usr/bin/env ruby

require 'httparty'
require 'dotenv/load'

# Load environment variables
BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}"
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json"
}

puts "Testing Bunny.net API credentials..."
puts "Library ID: #{ENV['BUNNY_LIBRARY_ID']}"
puts "API Key: #{ENV['BUNNY_API_KEY'][0..10]}..." # Show first 10 chars for security

begin
  response = HTTParty.get("#{BUNNY_API}/videos", headers: HEADERS)
  
  if response.success?
    puts "✅ Authentication successful!"
    puts "Found #{response.parsed_response['items'].size} videos"
  else
    puts "❌ Authentication failed: #{response.code} - #{response.body}"
  end
rescue => e
  puts "❌ Error: #{e.message}"
end 