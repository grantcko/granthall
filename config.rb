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

helpers do
  def fetch_vimeo_videos
    require 'httparty'

    begin
      user_id = ENV['USER_ID']
      album_id = ENV['ALBUM_ID']
      access_token = ENV['VIMEO_ACCESS_TOKEN']

      # Early return with empty data if env vars are missing
      return { 'data' => [] } if [user_id, album_id, access_token].any?(&:nil?)

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
        puts "URL attempted: #{url}"  # Add this for debugging
        { 'data' => [] }  # Return empty data instead of failing
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
