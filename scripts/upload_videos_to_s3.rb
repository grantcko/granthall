#!/usr/bin/env ruby

require 'aws-sdk-s3'
require 'json'
require 'dotenv/load'
require 'pathname'

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

def upload_folder(local_folder)
  s3_client = Aws::S3::Client.new(
    region: ENV['AWS_REGION'],
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
  )
  bucket = ENV['AWS_BUCKET_NAME']

  # Verify AWS credentials and bucket
  puts "\n🔍 Checking AWS configuration..."
  puts "Bucket: #{bucket}"
  puts "Region: #{ENV['AWS_REGION']}"

  folder_name = File.basename(local_folder)
  base_s3_path = "videos/#{folder_name}"

  required_files = {
    video: File.join(local_folder, 'original.mp4'),
    thumbnail: File.join(local_folder, 'thumbnail.png'),
    metadata: File.join(local_folder, 'metadata.json')
  }

  # Check if all required files exist
  missing_files = required_files.select { |_, path| !File.exist?(path) }
  if missing_files.any?
    puts "❌ Missing required files in #{folder_name}:"
    missing_files.each { |type, path| puts "  - #{type}: #{path}" }
    return false
  end

  # Upload each file
  required_files.each do |type, local_path|
    s3_key = "#{base_s3_path}/#{File.basename(local_path)}"
    success = upload_file(s3_client, bucket, local_path, s3_key)
    return false unless success
  end

  true
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

puts "🎥 Video Upload Script"
puts "===================="
puts "Base directory: #{base_path}"

# Process each numbered folder
success_count = 0
error_count = 0

Dir.glob(File.join(base_path, '*')).sort.each do |folder|
  next unless File.directory?(folder)
  folder_name = File.basename(folder)

  puts "\n📁 Processing folder: #{folder_name}"
  if upload_folder(folder)
    success_count += 1
    puts "✅ Successfully uploaded folder #{folder_name}"
  else
    error_count += 1
    puts "❌ Failed to upload folder #{folder_name}"
  end
end

puts "\n🎉 Upload complete!"
puts "===================="
puts "✅ Successful uploads: #{success_count}"
puts "❌ Failed uploads: #{error_count}"
