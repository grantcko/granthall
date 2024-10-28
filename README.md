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
- ☐ Redo the Videos page
- ☐ Add a contact form
- ☐ Upload videos to Vimeo

## Development

The site uses:
- ERB templates for views
- SCSS for styling
- Bootstrap for layout
- HTTParty for API requests

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
