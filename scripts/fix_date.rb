#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'time'
require 'dotenv/load'

BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}/videos"
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json",
  "content-type" => "application/json"
}

response = HTTParty.get(BUNNY_API, headers: HEADERS)

if response.success?
  video = response.parsed_response['items'].find { |v| v['title'] == 'Yeah OK, Dad' }

  if video
    other_tags = video['metaTags']&.reject { |tag| tag['property'] == 'created_date' } || []
    meta_tags = other_tags + [{ property: 'created_date', value: '2020-06-24T12:00:00Z' }]

    update_response = HTTParty.post(
      "#{BUNNY_API}/#{video['guid']}",
      headers: HEADERS,
      body: {
        title: video['title'],
        metaTags: meta_tags
      }.to_json
    )

    if update_response.success?
      puts "✅ Updated 'Yeah OK, Dad' with correct date format"
    else
      puts "❌ Update failed: #{update_response.code} - #{update_response.body}"
    end
  else
    puts "❌ Video not found"
  end
else
  puts "❌ Error fetching videos: #{response.code}"
end
