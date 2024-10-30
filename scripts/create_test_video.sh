#!/bin/zsh

# Create test directory
TEST_DIR="tmp/003"
mkdir -p $TEST_DIR

# Generate 1 second black video with ffmpeg
ffmpeg -f lavfi -i color=c=black:s=1920x1080:d=1 -c:v libx264 "$TEST_DIR/original.mp4"

# Generate a black thumbnail
ffmpeg -f lavfi -i color=c=black:s=1920x1080:d=1 -vframes 1 "$TEST_DIR/thumbnail.png"

# Create metadata.json
cat > "$TEST_DIR/metadata.json" << EOF
{
  "title": "Test Video 003",
  "description": "A test video for AWS S3",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "tags": ["test"]
}
EOF

# Upload to S3 if AWS CLI is configured
if command -v aws >/dev/null 2>&1; then
  echo "Uploading to S3..."
  aws s3 cp "$TEST_DIR" "s3://$AWS_BUCKET_NAME/videos/003" --recursive
  echo "Upload complete!"
else
  echo "AWS CLI not found. Files created in $TEST_DIR"
  echo "You can manually upload these files to S3"
fi

# List created files
echo "\nCreated files in $TEST_DIR:"
ls -la $TEST_DIR
