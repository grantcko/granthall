#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'time'
require 'dotenv/load'
require 'open3'

BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}/videos"
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json",
  "content-type" => "application/json"
}

def upload_video(path, title, description, date)
  puts "\n📽️  Processing: #{File.basename(path)}"

  # Create initial video entry
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

  # Upload the actual video file using Open3
  puts "📤 Uploading video file..."

  cmd = [
    'curl',
    '-X', 'PUT',
    '-H', "AccessKey: #{HEADERS['AccessKey']}",
    '-H', 'Content-Type: video/mp4',
    '-T', path,
    "#{BUNNY_API}/#{video_id}"
  ]

  stdout, stderr, status = Open3.capture3(*cmd)

  unless status.success?
    puts "❌ Failed to upload video file"
    puts "Error: #{stderr}"
    return
  end

  puts "✅ Upload complete"

  # Set the creation date
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

# The two problem files with their metadata
VIDEOS = [
  {
    path: '/Volumes/TASTY/videos/MY ARM CONDITION, a stop motion movie [IrhE_MdyErQ].webm',
    title: 'MY ARM CONDITION',
    description: 'A man has an arm condition. Another man has a solution. Made with legos and a stop motion app on an Ipad mini.',
    date: '2014-02-25'
  },
  {
    path: '/Volumes/TASTY/videos/Can Implosion!!! [c45ZQu89BE8].mp4',
    title: 'Can Implosion!!!',
    description: 'Grant shows how to implode a can with water and heat',
    date: '2014-02-25'
  }
]

puts "🎥 Uploading problem files..."

VIDEOS.each_with_index do |video, index|
  puts "\n[#{index + 1}/#{VIDEOS.size}] Uploading..."
  upload_video(video[:path], video[:title], video[:description], video[:date])
end

puts "\n✨ All uploads complete!"
