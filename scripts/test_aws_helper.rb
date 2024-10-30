require 'bundler/setup'
require 'dotenv/load'
require 'json'
require_relative '../helpers/aws_video_helper'

include AwsVideoHelper

# Clean up CloudFront URL if it's duplicated
cloudfront_url = ENV['CLOUDFRONT_URL'].to_s.strip
cloudfront_url = cloudfront_url.split.last if cloudfront_url.include?("\n")
ENV['CLOUDFRONT_URL'] = cloudfront_url

puts "Environment Variables Check:"
puts "=========================="
puts "AWS_REGION: #{ENV['AWS_REGION'] || 'NOT SET'}"
puts "AWS_ACCESS_KEY_ID: #{ENV['AWS_ACCESS_KEY_ID'] ? 'SET (hidden)' : 'NOT SET'}"
puts "AWS_SECRET_ACCESS_KEY: #{ENV['AWS_SECRET_ACCESS_KEY'] ? 'SET (hidden)' : 'NOT SET'}"
puts "AWS_BUCKET_NAME: #{ENV['AWS_BUCKET_NAME'] || 'NOT SET'}"
puts "CLOUDFRONT_URL: #{cloudfront_url || 'NOT SET'}"
puts "\n"

puts "Testing AWS Connection..."
puts "=========================="

begin
  result = fetch_aws_videos
  puts "\nSuccess! Here's what we got:"
  puts JSON.pretty_generate(result)
rescue => e
  puts "Error occurred:"
  puts e.message
  puts e.backtrace
end
