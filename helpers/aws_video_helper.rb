require 'aws-sdk-s3'
require 'aws-sdk-cloudfront'
require 'csv'

module AwsVideoHelper
  VIDEO_FORMATS = ['.mp4', '.mov', '.avi', '.wmv', '.flv', '.mkv', '.webm', '.m3u8']

  def fetch_aws_videos
    s3_client = Aws::S3::Client.new(
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )

    # Ensure we get the full CloudFront URL
    cloudfront_url = ENV['CLOUDFRONT_URL'].to_s.strip
    cloudfront_url = cloudfront_url.split.last if cloudfront_url.include?("\n")

    begin
      response = s3_client.list_objects_v2(
        bucket: ENV['AWS_BUCKET_NAME'],
        prefix: 'videos/'
      )

      videos = response.contents
        .select { |obj| obj.key.end_with?('original.mp4') }
        .map do |video_object|
          folder_path = File.dirname(video_object.key)
          folder_name = folder_path.split('/')[1] # Gets "001" from "videos/001"

          # Check for thumbnail
          thumbnail_key = "#{folder_path}/thumbnail.png"
          thumbnail_exists = response.contents.any? { |obj| obj.key == thumbnail_key }

          # Build URLs
          video_url = File.join(cloudfront_url, video_object.key)
          thumbnail_url = thumbnail_exists ? File.join(cloudfront_url, thumbnail_key) : nil

          {
            'id' => folder_name,
            'name' => folder_name,
            'description' => nil,
            'url' => video_url,
            'thumbnail_url' => thumbnail_url,
            'type' => 'mp4'
          }
        end

      { 'data' => videos }
    rescue => e
      puts "Error: #{e.message}"
      { 'data' => [] }
    end
  end
end
