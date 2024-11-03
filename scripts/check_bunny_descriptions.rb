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
    puts "\n🎥 Found #{videos.size} videos"

    videos_without_desc = []
    videos_with_desc = []

    videos.each do |video|
      title = video['title']
      description = video['metaTags']&.find { |tag| tag['property'] == 'description' }&.dig('value')

      if description
        videos_with_desc << "✅ #{title}: #{description}"
      else
        videos_without_desc << "❌ #{title}"
      end
    end

    puts "\n📝 Videos WITH description metaTag (#{videos_with_desc.size}):"
    puts videos_with_desc

    puts "\n⚠️  Videos WITHOUT description metaTag (#{videos_without_desc.size}):"
    puts videos_without_desc

    puts "\n📊 Summary:"
    puts "Total videos: #{videos.size}"
    puts "With description: #{videos_with_desc.size}"
    puts "Without description: #{videos_without_desc.size}"
  else
    puts "❌ Failed to fetch videos: #{response.code}"
    exit 1
  end
rescue => e
  puts "❌ Error: #{e.message}"
  exit 1
end
