# personal-profile
[THIS](https://granthall.me/) is my personal profile/porfolio website.


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
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
   - `AWS_REGION`: Your AWS region (e.g., us-east-1)
   - `AWS_BUCKET_NAME`: Your S3 bucket name
   - `CLOUDFRONT_URL`: Your CloudFront distribution URL

## Features
- Video hosting via AWS S3 and CloudFront
- Adaptive Bitrate (ABR) streaming
  - Automatic quality switching based on viewer's connection
  - Support for multiple devices and bandwidths
  - Quality variants: 240p, 360p, 720p, 1080p
  - HLS streaming protocol
- Dynamic video metadata management using S3 metadata.json files
- GitHub projects integration
- Responsive design
- Image optimization
- Bootstrap integration
- Video.js player integration

## Tools
- AWS S3 for video storage
- Spaceship for domain name service
- CloudFront for video delivery
- Video.js for video playback
- GitHub API for project integration
- Cloudinary for image hosting and optimization
- Bootstrap for responsive design
- Middleman for static site generation
- Ruby for scripting and automation
- Netlify for hosting and deployment

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

## AWS S3 bucket structure
your-bucket/
└── videos/
    └── folder_name/
        ├── original.mp4
        ├── thumbnail.png
        ├── metadata.json
        └── hls/
            ├── master.m3u8
            ├── 1080p.m3u8
            ├── 720p.m3u8
            ├── 360p.m3u8
            ├── 240p.m3u8
            └── segments/
                ├── 1080p_000.ts
                ├── 720p_000.ts
                └── ... (other segments)

## Development

The site uses:
- ERB templates for views
- SCSS for styling
- Bootstrap for layout
- HTTParty for API requests
- Justified Gallery (v3.8.1) for photo grid layout
- PhotoSwipe (v5.3.8) for image lightbox
- jQuery (v3.6.0) for Justified Gallery dependency
- Cloudinary for image hosting and optimization
  - Thumbnails: `w_800,q_auto,f_auto`
  - Fullsize: `w_800,q_95,f_auto`

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/modal-system`)
3. Commit your changes (`git commit -am 'Add video modal system'`)
4. Push to the branch (`git push origin modal-system`)
5. Open a Pull Request
