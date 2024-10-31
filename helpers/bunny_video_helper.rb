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
        videos = JSON.parse(response.body).map do |video|
          {
            id: video['guid'],
            name: video['title'],
            thumbnail_url: video['thumbnailUrl'],
            url: video['playbackUrl'],
            created_at: video['dateUploaded']
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
