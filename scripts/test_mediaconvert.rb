#!/usr/bin/env ruby

require 'bundler/setup'
require 'dotenv/load'
require 'json'
require_relative '../helpers/aws_video_helper'

include AwsVideoHelper

puts "🎥 MediaConvert Test"
puts "===================="

# First, verify our MediaConvert settings
puts "\n1. Checking MediaConvert settings..."
puts "Region: #{ENV['AWS_REGION']}"
puts "Endpoint: #{ENV['MEDIACONVERT_ENDPOINT']}"
puts "Queue ARN: #{ENV['MEDIACONVERT_QUEUE_ARN']}"
puts "Role ARN: #{ENV['MEDIACONVERT_ROLE_ARN']}"
puts "Bucket: #{ENV['AWS_BUCKET_NAME']}"

# Test with an existing video
TEST_VIDEO = "videos/999/original.mp4"

# Verify the source video exists
s3 = Aws::S3::Client.new(region: ENV['AWS_REGION'])
begin
  s3.head_object(bucket: ENV['AWS_BUCKET_NAME'], key: TEST_VIDEO)
  puts "\n✅ Source video exists in S3"
rescue Aws::S3::Errors::NotFound
  puts "\n❌ Source video not found in S3!"
  puts "Expected at: s3://#{ENV['AWS_BUCKET_NAME']}/#{TEST_VIDEO}"
  exit 1
end

puts "\n2. Creating HLS job for #{TEST_VIDEO}..."
puts "Input path: s3://#{ENV['AWS_BUCKET_NAME']}/#{TEST_VIDEO}"
puts "Output path: s3://#{ENV['AWS_BUCKET_NAME']}/#{File.dirname(TEST_VIDEO)}/hls/"

begin
  job_id = create_hls_video(TEST_VIDEO)

  if job_id
    puts "\n✅ MediaConvert job created successfully!"
    puts "Job ID: #{job_id}"
    puts "\n3. Job is now processing..."

    # Wait for job to complete (max 60 seconds)
    12.times do |i|
      sleep 5
      response = s3.list_objects_v2(
        bucket: ENV['AWS_BUCKET_NAME'],
        prefix: "#{File.dirname(TEST_VIDEO)}/hls/"
      )

      if response.contents.any?
        puts "\n4. HLS files created:"
        response.contents.each do |obj|
          puts "- #{obj.key} (#{obj.size} bytes)"
        end
        break
      else
        print "."
      end
    end
  else
    puts "❌ Failed to create MediaConvert job"
  end
rescue => e
  puts "\n❌ Error: #{e.message}"
  puts e.backtrace
end
