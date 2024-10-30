#!/bin/zsh

# Check if directory argument is provided
if [ "$1" ]; then
    cd "$1" || { echo "❌ Cannot access directory: $1"; exit 1; }
fi

# Set base directory
BASE_DIR="$(pwd)"
VIDEOS_DIR="$BASE_DIR"

echo "🎥 Video Organization Script"
echo "=========================="
echo "Working directory: $BASE_DIR"

# Function to sanitize input for JSON
sanitize_json() {
    echo "$1" | sed 's/"/\\"/g'
}

# First check if there are any video files
video_files=()
for ext in mp4 mov MP4 MOV; do
    if ls *.$ext >/dev/null 2>&1; then
        video_files+=(*.$ext)
    fi
done

if [ ${#video_files[@]} -eq 0 ]; then
    echo "❌ No video files found in current directory!"
    echo "Please place this script in a directory with video files."
    echo "Supported formats: .mp4, .mov"
    exit 1
fi

# Process each video file
count=1
for video in "${video_files[@]}"; do
    # Create padded folder number
    folder_num=$(printf "%03d" $count)
    folder_path="$VIDEOS_DIR/$folder_num"
    mkdir -p "$folder_path"

    echo "\n📁 Processing video: $video"
    echo "Creating folder: $folder_path"

    # Get video metadata
    echo "\n📝 Enter metadata for $video:"
    echo "Title (press enter to use filename):"
    read title
    title=${title:-${video%.*}}  # Use filename if no title given

    echo "Description:"
    read description

    echo "Tags (comma-separated):"
    read tags

    # Convert tags string to JSON array
    tags_json="["
    if [[ -n "$tags" ]]; then
        IFS=',' read -A tag_array <<< "$tags"
        for tag in "${tag_array[@]}"; do
            tags_json+="\"$(sanitize_json $(echo $tag | xargs))\","
        done
        tags_json=${tags_json%,}  # Remove trailing comma
    fi
    tags_json+="]"

    # Thumbnail handling
    echo "\n🖼  Add thumbnail? (y/N):"
    read add_thumbnail

    if [[ $add_thumbnail =~ ^[Yy]$ ]]; then
        echo "Enter path to thumbnail image:"
        read thumb_path
        if [[ -f "$thumb_path" ]]; then
            mv "$thumb_path" "$folder_path/thumbnail.png"
        else
            echo "⚠️  Thumbnail file not found, skipping thumbnail..."
        fi
    fi

    # If no thumbnail provided or file not found, generate one from video
    if [[ ! -f "$folder_path/thumbnail.png" ]]; then
        echo "📸 Generating thumbnail from video..."
        # Generate thumbnail using scene detection
        ffmpeg -i "$video" -vf "select=gt(scene\,0.4)" -frames:v 1 -vsync vfr "$folder_path/thumbnail.png" -y 2>/dev/null
        echo "✅ Generated thumbnail using scene detection"
    fi

    # Create metadata.json
    cat > "$folder_path/metadata.json" << EOF
{
    "title": "$(sanitize_json "$title")",
    "description": "$(sanitize_json "$description")",
    "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "tags": $tags_json
}
EOF

    # Move video file
    mv "$video" "$folder_path/original.mp4"

    echo "\n✅ Created folder $folder_num with:"
    ls -la "$folder_path"

    ((count++))
done

echo "\n🎉 Processing complete!"
echo "Files organized in: $VIDEOS_DIR"
