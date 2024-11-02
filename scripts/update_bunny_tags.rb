require 'httparty'
require 'tty-prompt'
require 'json'
require 'dotenv/load'

# Constants
BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}"
HEADERS = {
  'AccessKey' => ENV['BUNNY_API_KEY'],
  'accept' => 'application/json',
  'content-type' => 'application/json'
}

SAMPLE_TAGS = [
  'featured',
  'corporate',
  'documentary',
  'narrative',
  'music-video'
]

def display_video_info(video)
  print "✍️ \"#{video['title']}\" current tags: "
  current_tags = video['metaTags']&.find { |tag| tag['property'] == 'tags' }&.fetch('value', '')&.split(',') || []
  puts current_tags.join(', ')
  current_tags
end

def update_video_tags(video_id, title, selected_tags)
  tags_string = selected_tags.join(',')

  # Get current metaTags
  current_meta_tags = HTTParty.get(
    "#{BUNNY_API}/videos/#{video_id}",
    headers: HEADERS
  ).parsed_response['metaTags'] || []

  # Remove existing 'tags' entry if it exists
  current_meta_tags.reject! { |tag| tag['property'] == 'tags' }

  # Add new tags (only if there are any selected)
  current_meta_tags << { property: 'tags', value: tags_string } if selected_tags.any?

  # Update the video with new tags
  response = HTTParty.post(
    "#{BUNNY_API}/videos/#{video_id}",
    headers: HEADERS,
    body: { metaTags: current_meta_tags }.to_json
  )

  if response.success?
    puts "✅ Updated tags for \"#{title}\": #{tags_string}"
  else
    puts "❌ Failed to update tags for \"#{title}\": #{response.code} - #{response.body}"
  end
end

begin
  # Get video title from command line argument (optional)
  video_title = ARGV[0]

  response = HTTParty.get(
    "#{BUNNY_API}/videos",
    headers: HEADERS
  )

  if response.success?
    videos = response.parsed_response['items']
    prompt = TTY::Prompt.new

    if video_title
      # Single video mode
      video = videos.find { |v| v['title'].downcase == video_title.downcase }

      unless video
        puts "❌ Video not found: #{video_title}"
        exit 1
      end

      videos = [video] # Convert to array of one for consistent processing
    end

    # Process videos (either all or just one)
    videos.each do |video|
      begin
        current_tags = display_video_info(video)
        selected_tags = prompt.multi_select(
          "Select/deselect tags:",
          SAMPLE_TAGS,
          default: current_tags & SAMPLE_TAGS
        )

        update_video_tags(video['guid'], video['title'], selected_tags)
      rescue Interrupt
        puts "\nExiting..."
        exit 0
      end
    end
  else
    puts "❌ Failed to fetch videos: #{response.code} - #{response.body}"
    exit 1
  end
rescue StandardError => e
  puts "❌ An error occurred: #{e.message}"
  exit 1
end
