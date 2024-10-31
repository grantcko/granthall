#!/usr/bin/env ruby

require 'bundler/setup'
require 'dotenv/load'
require 'aws-sdk-s3'
require_relative '../helpers/aws_video_helper'

include AwsVideoHelper

puts "🎥 Converting All Videos to HLS"
puts "=============================="

s3 = Aws::S3::Client.new(region: ENV['AWS_REGION'])

# List all video folders
response = s3.list_objects_v2(
  bucket: ENV['AWS_BUCKET_NAME'],
  prefix: 'videos/',
  delimiter: '/'
)

response.common_prefixes.each do |prefix|
  folder = prefix.prefix
  video_id = folder.split('/')[1]

  puts "\nProcessing video #{video_id}..."

  # Check if original video exists
  video_key = "#{folder}video.mp4"
  begin
    s3.head_object(bucket: ENV['AWS_BUCKET_NAME'], key: video_key)
  rescue Aws::S3::Errors::NotFound
    puts "❌ No video file found in #{folder}"
    next
  end

  # Check if HLS version already exists
  hls_key = "#{folder}hls/stream/video.m3u8"
  begin
    s3.head_object(bucket: ENV['AWS_BUCKET_NAME'], key: hls_key)
    puts "✓ HLS version already exists, skipping"
    next
  rescue Aws::S3::Errors::NotFound
    # HLS doesn't exist, proceed with conversion
  end

  # Convert to HLS
  puts "Creating HLS version..."
  job_id = create_hls_video(video_key)

  if job_id
    puts "✅ Conversion started (Job ID: #{job_id})"
    puts "\nTo check the files:"
    puts "aws s3 ls s3://#{ENV['AWS_BUCKET_NAME']}/#{folder}hls/stream/"
  else
    puts "❌ Conversion failed"
  end

  # Wait a bit between jobs to avoid rate limiting
  sleep 2
end

puts "\n🎉 All videos processed!"
