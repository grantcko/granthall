#!/usr/bin/env ruby

require 'aws-sdk-s3'
require 'json'
require 'dotenv/load'

def check_folder_structure
  s3_client = Aws::S3::Client.new(
    region: ENV['AWS_REGION'],
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
  )

  bucket = ENV['AWS_BUCKET_NAME']
  prefix = 'videos/'

  puts "\n🔍 Checking S3 folder structure in #{bucket}/#{prefix}"
  puts "=================================================="

  response = s3_client.list_objects_v2(
    bucket: bucket,
    prefix: prefix
  )

  folders = response.contents
    .map { |obj| obj.key.split('/')[1] }
    .uniq
    .compact
    .sort

  folders.each do |folder|
    puts "\n📁 Folder #{folder}:"

    # Check for required files
    files = response.contents.select { |obj| obj.key.start_with?("#{prefix}#{folder}/") }

    has_video = files.any? { |f| f.key.end_with?('original.mp4') }
    has_thumbnail = files.any? { |f| f.key.end_with?('thumbnail.png') }
    has_metadata = files.any? { |f| f.key.end_with?('metadata.json') }

    puts "  #{has_video ? '✅' : '❌'} Video file"
    puts "  #{has_thumbnail ? '✅' : '❌'} Thumbnail"
    puts "  #{has_metadata ? '✅' : '❌'} Metadata"

    if has_metadata
      begin
        metadata_obj = s3_client.get_object(
          bucket: bucket,
          key: "#{prefix}#{folder}/metadata.json"
        )
        metadata = JSON.parse(metadata_obj.body.read)
        puts "    📝 Title: #{metadata['title']}"
        puts "    🏷️  Tags: #{metadata['tags'].join(', ')}" if metadata['tags']
      rescue => e
        puts "    ⚠️  Error reading metadata: #{e.message}"
      end
    end
  end
end

check_folder_structure
