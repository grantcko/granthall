#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'time'
require 'dotenv/load'
require 'tty-prompt'

BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}/videos"
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json",
  "content-type" => "application/json"
}

def update_video_date(video_id, title, created_date, existing_meta_tags)
  other_tags = existing_meta_tags&.reject { |tag| tag['property'] == 'created_date' } || []
  meta_tags = other_tags + [{ property: 'created_date', value: created_date }]

  response = HTTParty.post(
    "#{BUNNY_API}/#{video_id}",
    headers: HEADERS,
    body: {
      title: title,
      metaTags: meta_tags
    }.to_json
  )

  if response.success?
    verify_response = HTTParty.get("#{BUNNY_API}/#{video_id}", headers: HEADERS)
    if verify_response.success?
      video = verify_response.parsed_response
      actual_date = video['metaTags']&.find { |tag| tag['property'] == 'created_date' }&.dig('value')
      puts "✅ Updated successfully. Cloud date: #{actual_date}"
    else
      puts "⚠️ Updated but couldn't verify: #{verify_response.code}"
    end
  else
    puts "❌ Update failed: #{response.code} - #{response.body}"
  end
end

prompt = TTY::Prompt.new
response = HTTParty.get(BUNNY_API, headers: HEADERS)

if response.success?
  videos = response.parsed_response['items'].map do |video|
    created_date = video['metaTags']&.find { |tag| tag['property'] == 'created_date' }&.dig('value')
    date_to_sort = created_date ? Time.parse(created_date) : Time.parse(video['dateUploaded'])
    [date_to_sort, video]
  end.sort_by(&:first).reverse

  choices = videos.map do |date, video|
    created_date = video['metaTags']&.find { |tag| tag['property'] == 'created_date' }&.dig('value') || 'Not set'
    {
      name: "#{video['title']} (Created: #{created_date})",
      value: video
    }
  end

  while true
    puts "\n🎥 Select a video to edit (or Ctrl+C to exit):\n"
    video = prompt.select("Choose video:", choices, per_page: 20)
    current_date = video['metaTags']&.find { |tag| tag['property'] == 'created_date' }&.dig('value')

    puts "\nCurrent created_date: #{current_date || 'Not set'}"
    if prompt.yes?("Would you like to update this date?")
      new_date = prompt.ask("Enter new date (YYYY-MM-DD):") do |q|
        q.validate(/^\d{4}-\d{2}-\d{2}$/)
        q.messages[:valid?] = 'Date must be in format YYYY-MM-DD'
      end

      update_video_date(video['guid'], video['title'], "#{new_date}T12:00:00Z", video['metaTags'])
    end
  end
else
  puts "❌ Error fetching videos: #{response.code}"
end
