#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'time'
require 'dotenv/load'
require 'tty-prompt'

unless ARGV[0]
  puts "❌ Please provide a folder path"
  puts "Usage: ruby scripts/batch_upload_videos.rb /path/to/videos"
  exit 1
end

FOLDER_PATH = ARGV[0]
BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}/videos"
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json",
  "content-type" => "application/json"
}

def parse_date(mmddyy)
  month = mmddyy[0..1]
  day = mmddyy[2..3]
  year = mmddyy[4..5]
  full_year = "20#{year}"
  "#{full_year}-#{month}-#{day}"
end

def upload_video(video_data)
  filename = video_data[:filename]
  title = video_data[:title]
  description = video_data[:description]
  video_path = video_data[:path]
  date = video_data[:date]

  puts "\n📽️  Processing: #{filename}"

  response = HTTParty.post(
    BUNNY_API,
    headers: HEADERS,
    body: {
      title: title,
      description: description
    }.to_json
  )

  unless response.success?
    puts "❌ Failed to create video entry: #{response.code} - #{response.body}"
    return
  end

  video_id = response['guid']
  puts "🆔 Video ID: #{video_id}"

  puts "📤 Uploading video file..."
  # Escape the file path for curl
  escaped_path = video_path.gsub(/([\[\]\s\(\)'"])/) { |m| "\\#{m}" }

  upload_result = system(
    'curl',
    '-X', 'PUT',
    '-H', "AccessKey: #{HEADERS['AccessKey']}",
    '-H', 'Content-Type: video/mp4',
    '-T', escaped_path,
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

def collect_video_data
  # Only look at immediate directory, include mp4, mov, webm, and mkv
  video_files = Dir.children(FOLDER_PATH)
                  .select { |f| f.match?(/\.(mp4|mov|webm|mkv)$/i) }
                  .map { |f| File.join(FOLDER_PATH, f) }

  if video_files.empty?
    puts "❌ No video files found in #{FOLDER_PATH}"
    return []
  end

  puts "🎥 Found #{video_files.size} videos to process"
  prompt = TTY::Prompt.new
  videos_to_upload = []

  video_files.each_with_index do |video_path, index|
    filename = File.basename(video_path)
    puts "\n[#{index + 1}/#{video_files.size}] Collecting data for: #{filename}"

    if prompt.yes?("Include this video?")
      default_title = File.basename(video_path, File.extname(video_path))
      title = prompt.ask("Enter title:", default: default_title)
      description = prompt.ask("Enter description:")
      mmddyy = prompt.ask("Enter creation date (MMDDYY):") do |q|
        q.validate(/^\d{6}$/)
        q.messages[:valid?] = 'Date must be in format MMDDYY (e.g., 102423 for Oct 24, 2023)'
      end

      videos_to_upload << {
        path: video_path,
        filename: filename,
        title: title,
        description: description,
        date: parse_date(mmddyy)
      }
    else
      puts "⏭️  Skipping..."
    end

    unless index == video_files.size - 1
      continue = prompt.yes?("\nContinue to next video?")
      unless continue
        puts "\n👋 Exiting data collection..."
        break
      end
    end
  end

  videos_to_upload
end

begin
  unless Dir.exist?(FOLDER_PATH)
    puts "❌ Folder not found: #{FOLDER_PATH}"
    exit 1
  end

  videos_to_upload = collect_video_data

  if videos_to_upload.empty?
    puts "No videos selected for upload."
    exit 0
  end

  puts "\n📋 Summary of videos to upload:"
  videos_to_upload.each do |video|
    puts "\n- #{video[:filename]}"
    puts "  Title: #{video[:title]}"
    puts "  Description: #{video[:description]}"
    puts "  Date: #{video[:date]}"
  end

  prompt = TTY::Prompt.new
  if prompt.yes?("\nProceed with uploads?")
    puts "\n🚀 Starting uploads..."
    videos_to_upload.each_with_index do |video, index|
      puts "\n[#{index + 1}/#{videos_to_upload.size}] Uploading..."
      upload_video(video)
    end
    puts "\n✨ All uployads complete!"
  else
    puts "\n👋 Exiting without uploading..."
  end

rescue Interrupt
  puts "\n\n👋 Gracefully exiting..."
rescue StandardError => e
  puts "\n❌ Error: #{e.message}"
ensure
  exit 0
end
