#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'dotenv/load'

# Using the same API constants as other scripts
BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}"
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json"
}

def get_status_emoji(status, encode_progress)
  case status
  when 4 then "✅ Ready"
  when 3 then "🔄 Encoding (#{encode_progress}%)"
  when 2 then "⏳ Processing"
  when 1 then "📤 Uploaded"
  when 0 then "🆕 Created"
  when 5 then "❌ Failed"
  when 6 then "🗑️ Deleted"
  else "❓ Unknown (#{status})"
  end
end

begin
  puts "🎥 Checking encode status for all videos..."

  response = HTTParty.get("#{BUNNY_API}/videos", headers: HEADERS)

  if response.success?
    videos = response.parsed_response['items']
    total = videos.length
    encoding_count = 0
    ready_count = 0
    failed_count = 0

    puts "\nFound #{total} videos:\n"

    videos.each do |video|
      status_emoji = get_status_emoji(video['status'], video['encodeProgress'])

      # Count different statuses
      case video['status']
      when 3 then encoding_count += 1
      when 4 then ready_count += 1
      when 5 then failed_count += 1
      end

      puts "#{status_emoji} - #{video['title']}"
      if video['status'] == 3
        puts "  └─ Progress: #{video['encodeProgress']}%"
        puts "  └─ Resolution: #{video['width']}x#{video['height']}"
      end
      if video['status'] == 5
        puts "  └─ Check messages: #{video['transcodingMessages'].join(', ')}"
      end
    end

    puts "\nSummary:"
    puts "✅ Ready: #{ready_count}"
    puts "🔄 Encoding: #{encoding_count}"
    puts "❌ Failed: #{failed_count}"
    puts "📊 Total: #{total}"

  else
    puts "❌ Failed to fetch videos: #{response.code} - #{response.body}"
    exit 1
  end

rescue StandardError => e
  puts "❌ Error: #{e.message}"
  exit 1
end
