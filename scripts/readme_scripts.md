# Video Management Scripts

## upload_video_to_bunny.rb
**Purpose:** Uploads a single video to Bunny.net with metadata.
**Usage:** Run the script with the video file path as an argument.

## check_bunny_descriptions.rb
**Purpose:** Checks for videos on Bunny.net that are missing descriptions.
**Usage:** Run the script to get a list of videos with and without descriptions.

## list_bunny_videos.rb
**Purpose:** Lists all videos from Bunny.net with titles and descriptions.
**Usage:** Run the script to see a sorted list of videos.

## reencode_videos.rb
**Purpose:** Initiates re-encoding of videos on Bunny.net.
**Usage:** Run the script to re-encode all videos. It asks for confirmation before proceeding.

## update_bunny_tags.rb
**Purpose:** Updates tags for videos on Bunny.net.
**Usage:** Run the script and follow the prompts to update video tags.

## edit_created_dates.rb
**Purpose:** Edits the 'created_date' metadata for videos on Bunny.net.
**Usage:** Run the script and follow the prompts to update the creation dates.

## batch_upload_videos.rb
**Purpose:** Uploads multiple videos to Bunny.net from a specified directory.
**Usage:** Run the script with a directory path as an argument.

## check_encode_status.rb
**Purpose:** Checks the encoding status of all videos on Bunny.net.
**Usage:** Run the script to see the encoding status and progress of videos.

## check_bunny_settings.rb
**Purpose:** Checks various settings and information for Bunny.net library and videos.
**Usage:** Run the script with optional video ID to check specific video settings.

## upload_thumbnails_to_bunny.rb
**Purpose:** Uploads thumbnails for videos to Bunny.net.
**Usage:** Run the script to upload thumbnails found in a specified directory.

## calculate_encode_cost.rb
**Purpose:** Calculates the encoding, streaming, and delivery costs for videos on Bunny.net.
**Usage:** Run the script to get a cost breakdown per video and total costs.

## start
**Purpose:** Opens specified URLs in the Brave Browser and starts the Middleman server.
**Usage:** Run the script to open development tools and start the server.

### Additional Notes
- All scripts require the `httparty` gem for making HTTP requests and the `dotenv` gem for loading environment variables.
- Some scripts use the `tty-prompt` gem for interactive user prompts.
- The `upload_thumbnails_to_bunny.rb` script also requires `uri`, `net/http`, `fileutils`, and `mini_magick` gems.
- The `batch_upload_videos.rb` script uses `curl` for uploading videos, which must be available in the system's PATH.
- The `start` script is a utility script for opening web pages and starting a local server, specific to the user's development environment.
- This README directory provides a quick reference to the purpose and usage of each script in your codebase. It's a helpful document for new developers or for your future reference.
- this readme was generated with ai and i didn't check it for accuracy....
