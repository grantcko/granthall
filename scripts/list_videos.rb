#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'time'
require 'dotenv/load'

BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}/videos"
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json"
}

response = HTTParty.get(BUNNY_API, headers: HEADERS)

if response.success?
  videos = response.parsed_response['items']

  # Convert videos to array with parsed dates and sort
  sorted_videos = videos.map do |video|
    created_date = video['metaTags']&.find { |tag| tag['property'] == 'created_date' }&.dig('value')
    # Use upload date as fallback if created_date is not set
    date_to_sort = created_date ? Time.parse(created_date) : Time.parse(video['dateUploaded'])
    [date_to_sort, video]
  end.sort_by(&:first).reverse  # Sort by date, newest first

  puts "\n🎥 Found #{videos.size} videos:\n\n"

  sorted_videos.each do |_, video|
    created_date = video['metaTags']&.find { |tag| tag['property'] == 'created_date' }&.dig('value')
    puts "Title: #{video['title']}"
    puts "Upload Date: #{video['dateUploaded']}"
    puts "Created Date: #{created_date || 'Not set'}"
    puts "Length: #{video['length']} seconds"
    puts "---"
  end
else
  puts "❌ Error fetching videos: #{response.code}"
end
