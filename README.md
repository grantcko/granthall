[![Netlify Status](https://api.netlify.com/api/v1/badges/6aef332a-b034-45c9-b503-55a8b2310cbf/deploy-status)](https://app.netlify.com/projects/hummusxpress/deploys)
# granthall.me
[This is my personal website.](https://granthall.me/) It includes my videos, photos, repos, and thoughts.

## TODO:
- x add individual video links
- x Add a contact form
- x Refactor
- o Redirect thegranthall.com to granthall.me
- o Increase security
- o Increase lighthouse score

## Bunny.net Integration 

### Overview
Bunny.net is used for video hosting, metadata management, and thumbnail handling. It provides a robust platform for serving video content efficiently.

### Video Structure
Videos in Bunny.net are organized using metadata tags for efficient categorization and retrieval:

#### Metadata Tags
Each video has two types of metadata tags:
1. **Created Date**
   ```json
   { "property": "created_at", "value": "YYYY-MM-DDT00:00:00Z" }
   ```
2. **Category Tags**
   ```json
   { "property": "tags", "value": "tag1,tag2,tag3" }
   ```

2. **Description**
   ```json
   { "property": "description", "value": "description of the video" }
   ```

#### Available Categories
- `featured`: Highlighted/best work
- `corporate`: Corporate/commercial projects
- `documentary`: Documentary-style videos
- `narrative`: Narrative/story-driven content
- `music-video`: Music video projects

### Features
- **Video Upload**: Videos are uploaded to Bunny.net using a Ruby script that automates the process.
- **Metadata Management**: Each video can have associated metadata, including title, description, tags, and upload date.
- **Thumbnail Support**: Thumbnails can be uploaded alongside videos to provide a visual preview.
- **Tagging System**: Videos can be tagged with predefined categories to facilitate organization and retrieval.
- **Video Playback**: Integrated with bunny.net player.
- **Premium Encoding**: [coming soon](https://docs.bunny.net/docs/premium-encoding)

### Scripts
- several scripts available for development and dealing with videos on bunny.net

### Usage
1. **Upload Videos**: Run the `upload_video_to_bunny.rb` script to upload videos and their metadata.
2. **Update Tags**: Use the `update_bunny_tags.rb` script to manage video tags interactively.
3. **Display Videos**: Videos are fetched and displayed on the website using the `BunnyVideoHelper` module.

### Environment Variables
To set up environment variables in Netlify:
1. Go to Site settings > Build & deploy
2. Click on "Environment variables"
3. Add the following variables:
   - `BUNNY_LIBRARY_ID`: Your Bunny.net library ID
   - `BUNNY_API_KEY`: Your Bunny.net API key
   - `USER_ID`: Your Vimeo user ID
   - `ALBUM_ID`: Your Vimeo album ID
   - `VIMEO_ACCESS_TOKEN`: Your Vimeo API access token
   - `GITHUB_ACCESS_TOKEN`: Your GitHub personal access token
   - `CLOUDINARY_CLOUD_NAME`: Your Cloudinary cloud name
   - `CLOUDINARY_API_KEY`: Your Cloudinary API key
   - `CLOUDINARY_API_SECRET`: Your Cloudinary API secret

## Tools
- **Bunny.net**: Video and photo hosting, optimization, metadata, and thumbnails
- **Spaceship**: Domain name service
- **GitHub API**: Project integration
- **Cloudinary**: Image hosting and optimization
- **Bootstrap**: Responsive design
- **Middleman**: Static site generation
- **Ruby**: Scripting and automation
- **Netlify**: Hosting and deployment
