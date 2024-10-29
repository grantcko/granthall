require 'aws-sdk-s3'
require 'aws-sdk-cloudfront'

module AwsVideoHelper
  VIDEO_FORMATS = ['.mp4', '.mov', '.avi', '.wmv', '.flv', '.mkv', '.webm', '.m3u8']

  def fetch_aws_videos(folder = nil)
    s3_client = Aws::S3::Client.new(
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )

    begin
      response = s3_client.list_objects_v2(
        bucket: ENV['AWS_BUCKET_NAME']
      )

      videos = response.contents.map do |object|
        # Check if file extension matches any video format
        next unless VIDEO_FORMATS.any? { |format| object.key.downcase.end_with?(format) }

        video_id = File.basename(object.key, '.*')
        extension = File.extname(object.key).downcase

        {
          'id' => video_id,
          'name' => video_id.gsub('_', ' ').capitalize,
          'description' => '',
          'url' => "#{ENV['CLOUDFRONT_URL']}/#{object.key}",
          'size' => format_size(object.size),
          'type' => extension[1..-1],  # Remove the dot from extension
          'created_at' => object.last_modified
        }
      end.compact

      { 'data' => videos }
    rescue => e
      puts "Error: #{e.message}"
      { 'data' => [] }
    end
  end

  private

  def format_size(size_in_bytes)
    units = ['B', 'KB', 'MB', 'GB']
    unit_index = 0
    size = size_in_bytes.to_f

    while size > 1024 && unit_index < units.length - 1
      size /= 1024
      unit_index += 1
    end

    "#{size.round(1)} #{units[unit_index]}"
  end
end
