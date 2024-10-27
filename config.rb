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

    user_id = ENV['USER_ID']
    album_id = ENV['ALBUM_ID']
    access_token = ENV['VIMEO_ACCESS_TOKEN']

    url = "https://api.vimeo.com/users/#{user_id}/albums/#{album_id}/videos"
    headers = {
      "Authorization" => "Bearer #{access_token}"
    }

    response = HTTParty.get(url, headers: headers)

    if response.success?
      JSON.parse(response.body)
    else
      puts "Error fetching videos: #{response.code} #{response.message}"
      {}
    end
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

# configure :build do
#   activate :minify_css
#   activate :minify_javascript
# end
