#!/usr/bin/env ruby

require 'uri'
require 'net/http'
require 'json'
require 'dotenv/load'
require 'fileutils'
require 'mini_magick'

VIDEOS_DIR = '/Volumes/TASTY/videos'
BUNNY_LIBRARY = ENV['BUNNY_LIBRARY_ID']
BUNNY_KEY = ENV['BUNNY_API_KEY']

def normalize_title(title)
  title.gsub(/[^0-9A-Za-z\s\-_]/, '').strip.gsub(/\s+/, '_')
end

def find_thumbnail(folder_path)
  Dir.glob(File.join(folder_path, '*3840x2160*.jpg')).first
end

def prepare_thumbnail(source_path)
  temp_path = "/tmp/thumb_#{Time.now.to_i}.jpg"
  image = MiniMagick::Image.open(source_path)
  image.resize "1920x1080>"
  image.quality(85)
  image.write(temp_path)
  temp_path
end

def upload_thumbnail(video_id, thumbnail_path)
  return unless thumbnail_path && File.exist?(thumbnail_path)

  puts "  📸 Found thumbnail: #{File.basename(thumbnail_path)}"

  optimized_path = prepare_thumbnail(thumbnail_path)
  puts "  🖼  Optimized thumbnail to 1920x1080"

  url = URI("https://video.bunnycdn.com/library/#{BUNNY_LIBRARY}/videos/#{video_id}/thumbnail")
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(url)
  request["accept"] = "application/json"
  request["AccessKey"] = BUNNY_KEY
  request["content-type"] = "image/jpeg"
  request.body = File.read(optimized_path)

  response = http.request(request)
  FileUtils.rm(optimized_path)

  if response.code == "200"
    puts "  ✅ Thumbnail uploaded successfully"
    true
  else
    puts "  ❌ Failed to upload thumbnail: #{response.code} - #{response.body}"
    false
  end
end

def fetch_videos
  url = URI("https://video.bunnycdn.com/library/#{BUNNY_LIBRARY}/videos")
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(url)
  request["accept"] = "application/json"
  request["AccessKey"] = BUNNY_KEY

  response = http.request(request)

  if response.code == "200"
    JSON.parse(response.body)["items"]
  else
    puts "❌ Failed to fetch videos: #{response.code}"
    []
  end
end

begin
  puts "📥 Fetching videos from Bunny CDN..."
  videos = fetch_videos

  if videos.any?
    puts "\n🎥 Found #{videos.size} videos"
    updated_count = 0

    videos.each do |video|
      title = video['title']
      folder_name = normalize_title(title)
      folder_path = File.join(VIDEOS_DIR, folder_name)

      puts "\n📁 Processing: #{title}"

      if Dir.exist?(folder_path)
        thumbnail_path = find_thumbnail(folder_path)
        if thumbnail_path
          updated_count += 1 if upload_thumbnail(video['guid'], thumbnail_path)
        else
          puts "  ⚠️  No thumbnail found in: #{folder_path}"
        end
      else
        puts "  ⚠️  Folder not found: #{folder_path}"
      end
    end

    puts "\n🎉 Upload complete!"
    puts "Updated #{updated_count} thumbnails"
  end
rescue => e
  puts "❌ Error: #{e.message}"
  exit 1
end
