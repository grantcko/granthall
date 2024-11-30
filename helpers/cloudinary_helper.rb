module CloudinaryHelper
  def cloudinary_config
    {
      cloud_name: ENV['CLOUDINARY_CLOUD_NAME'],
      api_key: ENV['CLOUDINARY_API_KEY'],
      api_secret: ENV['CLOUDINARY_API_SECRET']
    }
  end

  def fetch_cloudinary_photos
    require 'cloudinary'
    require 'cloudinary/api'

    folder_name = 'granthall/photos/'

    begin
      # Debug output for environment variables
      puts "\n=== Cloudinary Configuration ==="
      puts "CLOUD_NAME: #{ENV['CLOUDINARY_CLOUD_NAME'] ? 'set' : 'not set'}"
      puts "API_KEY: #{ENV['CLOUDINARY_API_KEY'] ? 'set' : 'not set'}"
      puts "API_SECRET: #{ENV['CLOUDINARY_API_SECRET'] ? 'set' : 'not set'}"

      # Configure Cloudinary
      Cloudinary.config do |config|
        config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']
        config.api_key = ENV['CLOUDINARY_API_KEY']
        config.api_secret = ENV['CLOUDINARY_API_SECRET']
      end

      puts "\n=== Making API Request ==="
      puts "Requesting photos from folder: #{folder_name}"

      # Fetch all images
      result = Cloudinary::Api.resources(
        type: 'upload',
        prefix: folder_name,
        max_results: 500
      )

      puts "\n=== API Response ==="
      puts "Total photos found: #{result['resources'].length}"
      puts "First few photos:"
      result['resources'].first(3).each do |photo|
        puts "- #{photo['public_id']} (#{photo['format']})"
      end

      result['resources']
    rescue => e
      puts "\n=== ERROR ==="
      puts "Error fetching Cloudinary photos: #{e.message}"
      puts "Backtrace:"
      puts e.backtrace.first(5)
      []
    end
  end
end
