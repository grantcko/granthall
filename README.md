# personal-profile
[THIS](https://granthall.me/) is my personal profile/porfolio website.

Hosting: Netlify

Domain name service: [spaceship](https://spaceship.com)

## Environment Variables

To set up environment variables in Netlify:
1. Go to Site settings > Build & deploy
2. Click on "Environment variables"
3. Add the following variables:
   - `USER_ID`: Your Vimeo user ID
   - `ALBUM_ID`: Your Vimeo album ID
   - `VIMEO_ACCESS_TOKEN`: Your Vimeo API access token
   - `GITHUB_ACCESS_TOKEN`: Your GitHub personal access token

## Features
- Dynamic video loading from Vimeo API
- GitHub projects integration
- Responsive design
- Image optimization
- Bootstrap integration

## TODO:
- ☐ Implement video modal system:
  - Add click-to-expand functionality for video thumbnails
  - Create Bootstrap modal for video playback
  - Implement video controls in modal view
  - Add video description and metadata in modal
  - Include close button and escape key functionality
- ☐ Add a contact form
- ☐ Upload videos to Vimeo
- ☐ Add video category tags
- ☐ make thumbnails for top videos  on vimeo
- ☐ implement AWS video and image hosting like [this](https://www.youtube.com/watch?v=JbVyTrfqshU)

## Development

The site uses:
- ERB templates for views
- SCSS for styling
- Bootstrap for layout
- HTTParty for API requests

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/modal-system`)
3. Commit your changes (`git commit -am 'Add video modal system'`)
4. Push to the branch (`git push origin modal-system`)
5. Open a Pull Request
