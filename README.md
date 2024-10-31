# personal-profile
[THIS](https://granthall.me/) is my personal profile/porfolio website.

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
- ☐ Add a contact forma
- ☐ redirect thegranthall.com to granthall.me
- ☐ increase security

## Environment Variables

To set up environment variables in Netlify:
1. Go to Site settings > Build & deploy
2. Click on "Environment variables"
3. Add the following variables:
   - `USER_ID`: Your Vimeo user ID
   - `ALBUM_ID`: Your Vimeo album ID
   - `VIMEO_ACCESS_TOKEN`: Your Vimeo API access token
   - `GITHUB_ACCESS_TOKEN`: Your GitHub personal access token
   - `CLOUDINARY_CLOUD_NAME`: Your Cloudinary cloud name
   - `CLOUDINARY_API_KEY`: Your Cloudinary API key
   - `CLOUDINARY_API_SECRET`: Your Cloudinary API secret
   - `BUNNY_LIBRARY_ID`: Your Bunny.net library ID
   - `BUNNY_API_KEY`: Your Bunny.net API key

## Tools
- Video and photo hosting + optimization, metadata, and thumbnails via Bunny.net
- Spaceship for domain name service
- Video.js for video playback
- GitHub API for project integration
- Cloudinary for image hosting and optimization
- Bootstrap for responsive design
- Middleman for static site generation
- Ruby for scripting and automation
- Netlify for hosting and deployment
