#!/usr/bin/env ruby

require 'bundler/setup'
require 'dotenv/load'
require 'aws-sdk-s3'

s3_client = Aws::S3::Client.new(region: ENV['AWS_REGION'])

puts "🎥 Renaming original.mp4 to video.mp4..."

response = s3_client.list_objects_v2(
  bucket: ENV['AWS_BUCKET_NAME'],
  prefix: 'videos/'
)

response.contents.each do |obj|
  next unless obj.key.end_with?('original.mp4')

  new_key = obj.key.gsub('original.mp4', 'video.mp4')
  puts "Renaming: #{obj.key} -> #{new_key}"

  # Copy with new name
  s3_client.copy_object(
    bucket: ENV['AWS_BUCKET_NAME'],
    copy_source: "#{ENV['AWS_BUCKET_NAME']}/#{obj.key}",
    key: new_key
  )

  # Delete original
  s3_client.delete_object(
    bucket: ENV['AWS_BUCKET_NAME'],
    key: obj.key
  )
end

puts "✅ Done renaming files"d
