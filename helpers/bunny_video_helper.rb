require 'httparty'
require 'json'

module BunnyVideoHelper
  def fetch_bunny_videos
    begin
      puts "Fetching videos from Bunny CDN..."
      response = HTTParty.get(
        "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}/videos",
        headers: {
          "AccessKey" => ENV['BUNNY_API_KEY'],
          "accept" => "application/json"
        }
      )

      puts "Response code: #{response.code}"
      puts "Response body: #{response.body[0..500]}"

      if response.success?
        videos = response.parsed_response['items'].map do |video|
          puts "Processing video: #{video['title']} (ID: #{video['guid']})"
          created_date = video['metaTags']&.find { |tag| tag['property'] == 'created_date' }&.dig('value')
          tags = video['metaTags']&.find { |tag| tag['property'] == 'tags' }&.dig('value')
          created_at = created_date ? Time.parse(created_date) : Time.parse(video['dateUploaded'])
          {
            id: video['guid'],
            name: video['title'],
            videoLibraryId: video['videoLibraryId'],
            thumbnail_url: video['thumbnailFileName'] ? "https://#{ENV['BUNNY_PULL_ZONE_ID']}.b-cdn.net/#{video['guid']}/#{video['thumbnailFileName']}" : 'images/reel_placeholder.png',
            url: "https://iframe.mediadelivery.net/embed/#{ENV['BUNNY_LIBRARY_ID']}/#{video['guid']}",
            type: 'mp4',
            created_at: created_at,
            views: video['views'],
            length: video['length'],
            status: video['status'],
            tags: tags
          }
        end

        # Sort videos by created_at in descending order (newest first)
        videos.sort_by! { |video| video[:created_at] }.reverse!

        puts "Successfully processed #{videos.size} videos."
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
