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
TEST_VIDEO = "videos/004/original.mp4"

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
    puts "Check the AWS MediaConvert console for status:"
    puts "https://#{ENV['AWS_REGION']}.console.aws.amazon.com/mediaconvert/home"

    puts "\nHLS files will be created at:"
    puts "s3://#{ENV['AWS_BUCKET_NAME']}/#{File.dirname(TEST_VIDEO)}/hls/"

    puts "\nExpected output files:"
    puts "- master playlist: index.m3u8"
    puts "- 1080p playlist: 1080p.m3u8"
    puts "- 720p playlist: 720p.m3u8"
    puts "- 480p playlist: 480p.m3u8"
    puts "- video segments: *_*.ts"
  else
    puts "❌ Failed to create MediaConvert job"
  end
rescue => e
  puts "\n❌ Error: #{e.message}"
  puts "\nFull error details:"
  puts e.inspect
  puts "\nBacktrace:"
  puts e.backtrace
end
