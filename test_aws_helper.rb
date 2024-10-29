require 'bundler/setup'
require 'dotenv/load'
require_relative 'helpers/aws_video_helper'

include AwsVideoHelper

puts "Environment Variables Check:"
puts "=========================="
puts "AWS_REGION: #{ENV['AWS_REGION'] || 'NOT SET'}"
puts "AWS_ACCESS_KEY_ID: #{ENV['AWS_ACCESS_KEY_ID'] ? 'SET (hidden)' : 'NOT SET'}"
puts "AWS_SECRET_ACCESS_KEY: #{ENV['AWS_SECRET_ACCESS_KEY'] ? 'SET (hidden)' : 'NOT SET'}"
puts "AWS_BUCKET_NAME: #{ENV['AWS_BUCKET_NAME'] || 'NOT SET'}"
puts "CLOUDFRONT_URL: #{ENV['CLOUDFRONT_URL'] || 'NOT SET'}"
puts "\n"

puts "Testing AWS Connection..."
puts "=========================="

begin
  result = fetch_aws_videos
  puts "Success! Here's what we got:"
  puts JSON.pretty_generate(result)
rescue => e
  puts "Error occurred:"
  puts e.message
  puts e.backtrace
end
