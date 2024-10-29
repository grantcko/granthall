# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

require_relative 'helpers/aws_video_helper'

helpers do
  include AwsVideoHelper

  def fetch_vimeo_videos(album_id)
    require 'httparty'

    begin
      user_id = ENV['USER_ID']
      access_token = ENV['VIMEO_ACCESS_TOKEN']

      # Debug output
      puts "Environment variables:"
      puts "USER_ID: #{user_id ? 'set' : 'not set'}"
      puts "ALBUM_ID: #{album_id ? 'set' : 'not set'}"
      puts "VIMEO_ACCESS_TOKEN: #{access_token ? 'set' : 'not set'}"

      # Early return with empty data if env vars are missing or contain placeholder values
      if [user_id, album_id, access_token].any? { |var| var.nil? || var.include?('your_') }
        puts "Warning: Using placeholder environment variables"
        return { 'data' => [] }
      end

      url = "https://api.vimeo.com/users/#{user_id}/albums/#{album_id}/videos?sort=manual"
      headers = {
        "Authorization" => "Bearer #{access_token}",
        "Content-Type" => "application/json"
      }

      response = HTTParty.get(url, headers: headers)

      if response.success?
        JSON.parse(response.body)
      else
        puts "Error fetching videos: #{response.code} #{response.message}"
        puts "URL attempted: #{url.gsub(access_token, '[REDACTED]')}"  # Don't log the actual token
        { 'data' => [] }
      end
    rescue => e
      puts "Error in fetch_vimeo_videos: #{e.message}"
      { 'data' => [] }
    end
  end

  def truncate_words(text, word_count = 10)
    return "" if text.nil?
    words = text.split
    words.length > word_count ? words.first(word_count).join(' ') + "..." : text
  end

  def fetch_github_pinned_repos
    require 'httparty'

    access_token = ENV['GITHUB_ACCESS_TOKEN']
    username = 'grantcko'

    url = "https://api.github.com/graphql"
    headers = {
      "Authorization" => "Bearer #{access_token}",
      "Content-Type" => "application/json"
    }

    query = <<~GQL
      {
        user(login: "#{username}") {
          pinnedItems(first: 6, types: REPOSITORY) {
            nodes {
              ... on Repository {
                name
                description
                url
                primaryLanguage {
                  name
                }
                stargazerCount
              }
            }
          }
        }
      }
    GQL

    response = HTTParty.post(url, headers: headers, body: { query: query }.to_json)

    if response.success?
      data = JSON.parse(response.body)
      pinned_repos = data['data']['user']['pinnedItems']['nodes']
      pinned_repos.map do |repo|
        {
          name: repo['name'],
          description: repo['description'],
          url: repo['url'],
          language: repo['primaryLanguage'] ? repo['primaryLanguage']['name'] : nil,
          stars: repo['stargazerCount']
        }
      end
    else
      puts "Error fetching pinned repos: #{response.code} #{response.message}"
      []
    end
  end

  def fetch_github_repos
    begin
      token = ENV['GITHUB_ACCESS_TOKEN']

      # Early return if token is missing or contains placeholder
      if token.nil? || token.include?('your_')
        puts "Warning: GitHub token not properly configured"
        return []
      end

      # Rest of your GitHub fetching code...
    rescue => e
      puts "Error fetching GitHub repos: #{e.message}"
      []
    end
  end

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

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

# This configuration is for setting up an external pipeline with Webpack during the build process.
# It activates the external pipeline, specifying the name as :webpack.
# The command to run depends on whether it's a build or start process.
# The source directory for the pipeline is '.tmp/dist' and the latency is set to 1.
#
# configure :build do
#   activate :external_pipeline,
#     name: :webpack,
#     command: build? ? 'yarn run build' : 'yarn run start',
#     source: '.tmp/dist',
#     latency: 1
# end

# Configure URLs to include or exclude .html extension
# Option 1: Remove .html from URLs (recommended for cleaner URLs)
# activate :directory_indexes
