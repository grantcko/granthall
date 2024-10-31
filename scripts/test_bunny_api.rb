require 'httparty'
require 'dotenv/load'

BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}/videos"
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json"
}

begin
  response = HTTParty.get(BUNNY_API, headers: HEADERS)

  if response.success?
    puts "Successfully fetched videos:"
    puts response.body
  else
    puts "Error fetching videos: #{response.code} - #{response.body}"
  end
rescue => e
  puts "An error occurred: #{e.message}"
end
