#!/usr/bin/env ruby

require 'bundler/setup'
require 'dotenv/load'
require 'aws-sdk-s3'

s3_client = Aws::S3::Client.new(region: ENV['AWS_REGION'])

puts "🗑️  Removing all HLS files..."

# List all video folders
response = s3_client.list_objects_v2(
  bucket: ENV['AWS_BUCKET_NAME'],
  prefix: 'videos/',
  delimiter: '/'
)

response.common_prefixes.each do |prefix|
  folder = prefix.prefix
  hls_path = "#{folder}hls/"

  puts "\nChecking #{folder}..."

  # List all HLS files
  hls_response = s3_client.list_objects_v2(
    bucket: ENV['AWS_BUCKET_NAME'],
    prefix: hls_path
  )

  if hls_response.contents.any?
    puts "Deleting HLS files..."
    hls_response.contents.each do |obj|
      s3_client.delete_object(
        bucket: ENV['AWS_BUCKET_NAME'],
        key: obj.key
      )
      puts "  ✓ Deleted #{obj.key}"
    end
  else
    puts "No HLS files found"
  end
end

puts "\n✅ Done removing HLS files"
