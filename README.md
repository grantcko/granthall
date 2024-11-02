# personal-profile
[THIS](https://granthall.me/) is my personal profile/portfolio website.

## TODO:
- ☑ Upload videos to Vimeo
- ☑ make thumbnails for top videos on vimeo
- ☑ implement AWS video and image hosting like [this](https://www.youtube.com/watch?v=JbVyTrfqshU
- setup tagging
- setup thumbnails
- ☑ upload videos, upload thumbnails, write metadata
- ☑ Implement video modal system:
- ☐ optimize videos
- ☐ add individual video links
- ☐ Add video category tags
- ☐ Add a contact form
- ☐ Redirect thegranthall.com to granthall.me
- ☐ Increase security

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
- **Video Playback**: Integrated with Video.js for seamless video playback on the website.

### Scripts
- **`upload_video_to_bunny.rb`**: A script to upload videos to Bunny.net. It prompts for video file path, thumbnail, and metadata, then uploads the content.
- **`update_bunny_tags.rb`**: Allows updating of video tags using a user-friendly interface with `tty-prompt`.

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
- **Video.js**: Video playback
- **GitHub API**: Project integration
- **Cloudinary**: Image hosting and optimization
- **Bootstrap**: Responsive design
- **Middleman**: Static site generation
- **Ruby**: Scripting and automation
- **Netlify**: Hosting and deployment
