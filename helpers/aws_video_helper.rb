require 'aws-sdk-s3'
require 'aws-sdk-cloudfront'
require 'aws-sdk-mediaconvert'
require 'csv'

module AwsVideoHelper
  # List of video formats we support in the system
  VIDEO_FORMATS = ['.mp4', '.mov', '.avi', '.wmv', '.flv', '.mkv', '.webm', '.m3u8']

  def create_hls_video(input_key)
    client = Aws::MediaConvert::Client.new(
      region: ENV['AWS_REGION'],
      endpoint: ENV['MEDIACONVERT_ENDPOINT']
    )

    video_id = input_key.split('/')[1]
    hls_path = "#{File.dirname(input_key)}/hls/stream"

    job_settings = {
      role: ENV['MEDIACONVERT_ROLE_ARN'],
      settings: {
        timecode_config: {
          source: "ZEROBASED"
        },
        inputs: [{
          file_input: "s3://#{ENV['AWS_BUCKET_NAME']}/#{input_key}",
          audio_selectors: {
            "Audio Selector 1": {
              default_selection: "DEFAULT"
            }
          }
        }],
        output_groups: [{
          name: "HLS",
          output_group_settings: {
            type: "HLS_GROUP_SETTINGS",
            hls_group_settings: {
              segment_length: 6,
              min_segment_length: 0,
              destination: "s3://#{ENV['AWS_BUCKET_NAME']}/#{hls_path}/",
              segment_control: "SEGMENTED_FILES",
              output_selection: "MANIFESTS_AND_SEGMENTS"
            }
          },
          outputs: [
            # 1080p
            {
              name_modifier: "_1080p",
              video_description: {
                width: 1920,
                height: 1080,
                codec_settings: {
                  codec: "H_264",
                  h264_settings: {
                    rate_control_mode: "QVBR",
                    max_bitrate: 5000000
                  }
                }
              }
            },
            # 720p
            {
              name_modifier: "_720p",
              video_description: {
                width: 1280,
                height: 720,
                codec_settings: {
                  codec: "H_264",
                  h264_settings: {
                    rate_control_mode: "QVBR",
                    max_bitrate: 3000000
                  }
                }
              }
            },
            # 480p
            {
              name_modifier: "_480p",
              video_description: {
                width: 854,
                height: 480,
                codec_settings: {
                  codec: "H_264",
                  h264_settings: {
                    rate_control_mode: "QVBR",
                    max_bitrate: 1000000
                  }
                }
              }
            }
          ].map do |output|
            output.merge({
              container_settings: { container: "M3U8" },
              audio_descriptions: [{
                codec_settings: {
                  codec: "AAC",
                  aac_settings: {
                    rate_control_mode: "CBR",
                    bitrate: 96000,
                    coding_mode: "CODING_MODE_2_0",
                    sample_rate: 48000
                  }
                }
              }]
            })
          end
        }]
      }
    }

    response = client.create_job(job_settings)
    response.job.id
  rescue Aws::MediaConvert::Errors::ServiceError => e
    puts "❌ Error: #{e.message}"
    nil
  end

  def fetch_aws_videos
    s3_client = Aws::S3::Client.new(
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )

    begin
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
        .select { |obj| obj.key.end_with?('video.mp4') }
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
