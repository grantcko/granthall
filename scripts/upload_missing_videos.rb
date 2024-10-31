#!/usr/bin/env ruby

require 'aws-sdk-s3'
require 'json'
require 'dotenv/load'
require 'pathname'

def check_file_exists(s3_client, bucket, key)
  s3_client.head_object(bucket: bucket, key: key)
  true
rescue Aws::S3::Errors::NotFound
  false
end

def upload_file(s3_client, bucket, local_path, s3_key)
  puts "📤 Uploading: #{s3_key}"
  File.open(local_path, 'rb') do |file|
    s3_client.put_object(
      bucket: bucket,
      key: s3_key,
      body: file,
      content_type: content_type_for(local_path)
    )
  end
  puts "✅ Uploaded: #{s3_key}"
  true
rescue => e
  puts "❌ Error uploading #{s3_key}: #{e.message}"
  false
end

def content_type_for(file_path)
  case File.extname(file_path).downcase
  when '.mp4' then 'video/mp4'
  when '.png' then 'image/png'
  when '.json' then 'application/json'
  else 'application/octet-stream'
  end
end

def upload_missing_files(local_folder)
  s3_client = Aws::S3::Client.new(
    region: ENV['AWS_REGION'],
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
  )
  bucket = ENV['AWS_BUCKET_NAME']

  folder_name = File.basename(local_folder)
  base_s3_path = "videos/#{folder_name}"

  required_files = {
    video: ['original.mp4', 'video/mp4'],
    thumbnail: ['thumbnail.png', 'image/png'],
    metadata: ['metadata.json', 'application/json']
  }

  missing_files = {}

  # Check which files are missing in S3
  required_files.each do |type, (filename, content_type)|
    local_path = File.join(local_folder, filename)
    s3_key = "#{base_s3_path}/#{filename}"

    next unless File.exist?(local_path) # Skip if local file doesn't exist

    if !check_file_exists(s3_client, bucket, s3_key)
      missing_files[type] = {
        local_path: local_path,
        s3_key: s3_key,
        content_type: content_type
      }
    end
  end

  return if missing_files.empty?

  puts "\n📁 Folder #{folder_name} missing files:"
  missing_files.each do |type, info|
    puts "  - #{type}: #{File.basename(info[:local_path])}"
  end

  # Upload missing files
  missing_files.each do |type, info|
    upload_file(s3_client, bucket, info[:local_path], info[:s3_key])
  end
end

# Main execution
if ARGV.empty?
  puts "❌ Usage: #{$0} <path_to_video_folders>"
  exit 1
end

base_path = ARGV[0]
unless Dir.exist?(base_path)
  puts "❌ Directory not found: #{base_path}"
  exit 1
end

puts "🔍 Checking for missing files..."
puts "Base directory: #{base_path}"

# Process each numbered folder
Dir.glob(File.join(base_path, '*')).sort.each do |folder|
  next unless File.directory?(folder)
  upload_missing_files(folder)
end

puts "\n🎉 Upload complete!"
