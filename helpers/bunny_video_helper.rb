require 'httparty'
require 'json'

module BunnyVideoHelper
  def fetch_bunny_videos
    begin
      response = HTTParty.get(
        "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}/videos",
        headers: {
          "AccessKey" => ENV['BUNNY_API_KEY'],
          "accept" => "application/json"
        }
      )

      if response.success?
        videos = response.parsed_response['items'].map do |video|
          {
            id: video['guid'],
            name: video['title'],
            thumbnail_url: video['thumbnailFileName'] ? "https://your-cdn-url/#{video['thumbnailFileName']}" : 'images/reel_placeholder.png',
            url: video['playbackUrl'],
            type: 'mp4', # Assuming the videos are in mp4 format
            created_at: video['dateUploaded'],
            views: video['views'],
            length: video['length'],
            status: video['status']
          }
        end
        { 'data' => videos }
      else
        puts "Error fetching videos: #{response.code} - #{response.body}"
        { 'data' => [] }
      end
    rescue => e
      puts "Error in fetch_bunny_videos: #{e.message}"
      { 'data' => [] }
    end
  end
end
