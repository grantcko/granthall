#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'time'
require 'dotenv/load'

BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}/videos"
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json",
  "content-type" => "application/json"
}

# Predefined dates from previous run
DATES = {
  'North Shore' => '2023-09-29',
  'NUTS 2018' => '2018-10-10',
  'ANOTHER' => '2024-02-19',
  'In Memory of a Treehouse' => '2024-10-27',
  'Tommy and Tony Say Thank You for 50 Subs!' => '2022-07-03',
  'Marlboro？' => '2022-05-24',
  'Big Road Trip Boys' => '2022-06-04',
  'Yeah OK, Dad' => '2020-24-06',
  'MAYA Highschool' => '2022-11-10',
  'Pancake Donuts' => '2018-09-03',
  'Paranoia' => '2019-05-09'
}

def update_video_date(video_id, title, created_date, existing_meta_tags)
  # Keep all existing meta tags except created_date
  other_tags = existing_meta_tags&.reject { |tag| tag['property'] == 'created_date' } || []

  # Add the new created_date tag
  meta_tags = other_tags + [{ property: 'created_date', value: created_date }]

  puts "Updating '#{title}' with created_date: #{created_date}"

  response = HTTParty.post(
    "#{BUNNY_API}/#{video_id}",
    headers: HEADERS,
    body: {
      title: title,
      metaTags: meta_tags
    }.to_json
  )

  if response.success?
    # Verify the update by fetching the video data
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

response = HTTParty.get(BUNNY_API, headers: HEADERS)

if response.success?
  videos = response.parsed_response['items']
  videos_without_date = videos.select do |video|
    created_date = video['metaTags']&.find { |tag| tag['property'] == 'created_date' }
    created_date.nil?
  end

  if videos_without_date.empty?
    puts "✨ No videos found without created_date"
    exit
  end

  puts "\n🎥 Found #{videos_without_date.size} videos without created_date:\n\n"

  videos_without_date.each do |video|
    if DATES[video['title']]
      puts "\nProcessing: #{video['title']}"
      puts "Length: #{video['length']} seconds"
      puts "Upload Date: #{video['dateUploaded']}"

      created_date = "#{DATES[video['title']]}T12:00:00Z"
      update_video_date(video['guid'], video['title'], created_date, video['metaTags'])
    else
      puts "⚠️ No predefined date for: #{video['title']}"
    end
  end

  puts "\n👋 All done!"
else
  puts "❌ Error fetching videos: #{response.code}"
end
