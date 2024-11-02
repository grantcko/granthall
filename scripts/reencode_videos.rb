#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'dotenv/load'

BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}"
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json"
}

def reencode_video(video_id, title)
  puts "🔄 Reencoding: #{title} (#{video_id})"

  response = HTTParty.post(
    "#{BUNNY_API}/videos/#{video_id}/reencode",
    headers: HEADERS
  )

  if response.success?
    puts "✅ Reencode initiated successfully"
  else
    puts "❌ Failed to initiate reencode: #{response.code} - #{response.body}"
  end
end

begin
  puts "📋 Fetching video list..."
  response = HTTParty.get(
    "#{BUNNY_API}/videos",
    headers: HEADERS
  )

  if response.success?
    videos = response.parsed_response['items']
    total = videos.length

    puts "\n🎥 Found #{total} videos to reencode"
    print "Continue? (y/N): "

    if STDIN.gets.chomp.downcase == 'y'
      videos.each_with_index do |video, index|
        puts "\n[#{index + 1}/#{total}]"
        reencode_video(video['guid'], video['title'])
        sleep 1 # Add a small delay between requests
      end
      puts "\n✨ Reencode requests completed!"
    else
      puts "Operation cancelled"
    end
  else
    puts "❌ Failed to fetch videos: #{response.code} - #{response.body}"
    exit 1
  end

rescue Interrupt
  puts "\n\n👋 Gracefully exiting..."
rescue StandardError => e
  puts "\n❌ Error: #{e.message}"
ensure
  exit 0
end
