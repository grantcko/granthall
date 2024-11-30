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
