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

VIDEOS = [
  {
    path: '/Volumes/TASTY/videos/MY ARM CONDITION, a stop motion movie.webm',
    title: 'MY ARM CONDITION',
    description: 'A man has an arm condition. Another man has a solution. Made with legos and a stop motion app on an Ipad mini.',
    date: '2014-02-25'
  },
  {
    path: '/Volumes/TASTY/videos/Can Implosion!!!.mp4',
    title: 'Can Implosion!!!',
    description: 'Grant shows how to implode a can with water and heat',
    date: '2014-02-25'
  }
]

def upload_video(path, title, description, date)
  puts "\n📽️  Processing: #{File.basename(path)}"

  response = HTTParty.post(
    BUNNY_API,
    headers: HEADERS,
    body: { title: title, description: description }.to_json
  )

  unless response.success?
    puts "❌ Failed to create video entry: #{response.code}"
    return
  end

  video_id = response['guid']
  puts "🆔 Video ID: #{video_id}"

  puts "📤 Uploading video file..."
  upload_result = system(
    'curl',
    '-X', 'PUT',
    '-H', "AccessKey: #{HEADERS['AccessKey']}",
    '-H', 'Content-Type: video/mp4',
    '-T', path,
    "#{BUNNY_API}/#{video_id}"
  )

  unless upload_result
    puts "❌ Failed to upload video file"
    return
  end

  puts "✅ Upload complete"

  meta_tags = [{ property: 'created_date', value: "#{date}T12:00:00Z" }]
  response = HTTParty.post(
    "#{BUNNY_API}/#{video_id}",
    headers: HEADERS,
    body: {
      title: title,
      description: description,
      metaTags: meta_tags
    }.to_json
  )

  if response.success?
    puts "✅ Created date set successfully: #{date}"
  else
    puts "⚠️ Failed to set created date: #{response.code}"
  end
end

puts "🎥 Uploading files..."

VIDEOS.each_with_index do |video, index|
  puts "\n[#{index + 1}/#{VIDEOS.size}] Uploading..."
  upload_video(video[:path], video[:title], video[:description], video[:date])
end

puts "\n✨ All uploads complete!"
