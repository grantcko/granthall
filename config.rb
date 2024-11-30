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

require_relative 'helpers/bunny_video_helper'
require_relative 'helpers/cloudinary_helper'
require_relative 'helpers/github_helper'


helpers do
  CloudinaryHelper
  BunnyVideoHelper

  def truncate_words(text, word_count = 10)
    return "" if text.nil?
    words = text.split
    words.length > word_count ? words.first(word_count).join(' ') + "..." : text
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

# Redirect configuration
redirect "reel/index.html", to: "/videos#cef04918-811d-4661-b218-373064b1dd9b"
redirect "treehouse/index.html", to: "/videos#c2fd0b3a-2d9b-4ce7-8e55-099c6bf5f30d"
