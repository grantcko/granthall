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

    begin
      # First, let's list ALL objects to debug
      response = s3_client.list_objects_v2(
        bucket: ENV['AWS_BUCKET_NAME'],
        prefix: 'videos/'
      )

      puts "\nAll objects in videos/:"
      response.contents.each do |obj|
        puts "- #{obj.key} (#{obj.last_modified})"
      end

      cloudfront_url = ENV['CLOUDFRONT_URL'].to_s.strip.split.last
      all_contents = response.contents
      videos = all_contents
        .select { |obj| obj.key.end_with?('original.mp4') }
        .map do |video_object|
          puts "\nProcessing video: #{video_object.key}"

          folder_name = video_object.key.split('/')[1]
          folder_path = File.dirname(video_object.key)

          metadata = {}
          begin
            metadata_response = s3_client.get_object(
              bucket: ENV['AWS_BUCKET_NAME'],
              key: "#{folder_path}/metadata.json"
            )
            metadata = JSON.parse(metadata_response.body.read)
            puts "Found metadata for #{folder_name}"
          rescue => e
            puts "No metadata found for #{folder_name}: #{e.message}"
          end

          thumbnail_key = "#{folder_path}/thumbnail.png"
          thumbnail_exists = all_contents.any? { |obj| obj.key == thumbnail_key }
          puts "Thumbnail exists: #{thumbnail_exists}"

          created_at = if metadata['created_at']
                        metadata['created_at']
                      else
                        video_object.last_modified.iso8601
                      end

          {
            'id' => folder_name,
            'name' => metadata['title'] || folder_name,
            'url' => File.join(cloudfront_url, video_object.key),
            'thumbnail_url' => thumbnail_exists ? File.join(cloudfront_url, thumbnail_key) : nil,
            'type' => 'mp4',
            'created_at' => created_at
          }
        end

      puts "\nProcessed #{videos.length} videos successfully"
      { 'data' => videos.sort_by { |v| v['id'] } }
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      { 'data' => [] }
    end
  end
end
