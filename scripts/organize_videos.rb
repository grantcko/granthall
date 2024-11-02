#!/usr/bin/env ruby

require 'json'
require 'fileutils'

# Check command line arguments
if ARGV.length < 2
  puts "❌ Usage: #{$0} <directory> <start_number>"
  exit 1
end

BASE_DIR = ARGV[0]
start_count = ARGV[1].to_i

# Change to base directory
begin
  Dir.chdir(BASE_DIR)
rescue
  puts "❌ Cannot access directory: #{BASE_DIR}"
  exit 1
end

puts "🎥 Video Organization Script"
puts "=========================="
puts "Working directory: #{BASE_DIR}"

# Print existing video titles
puts "\n📋 Existing videos in numbered folders:"
Dir.glob("*/metadata.json").sort.each do |metadata_file|
  begin
    metadata = JSON.parse(File.read(metadata_file))
    folder = File.dirname(metadata_file)
    puts "#{folder}: #{metadata['title']}"
  rescue JSON::ParserError
    puts "#{folder}: ⚠️  Invalid metadata file"
  end
end
puts "\n"

# Find video files
video_files = Dir["*.{mp4,mov,MP4,MOV}"]

if video_files.empty?
  puts "❌ No video files found in current directory!"
  puts "Please place this script in a directory with video files."
  puts "Supported formats: .mp4, .mov"
  exit 1
end

# Process each video file
count = start_count
video_files.each do |video|
  folder_num = "%03d" % count
  folder_path = File.join(BASE_DIR, folder_num)
  FileUtils.mkdir_p(folder_path)

  puts "\n📁 Processing video: #{video}"
  puts "Creating folder: #{folder_path}"

  puts "\n📝 Enter metadata for #{video}:"
  print "Title (press enter to use filename): "
  title = STDIN.gets.chomp
  title = File.basename(video, ".*") if title.empty?

  print "Description: "
  description = STDIN.gets.chomp

  print "Tags (comma-separated): "
  tags = STDIN.gets.chomp

  puts "\nEnter creation date (press enter to use file metadata):"
  print "Day (1-31 or enter for auto): "
  input = STDIN.gets.chomp

  if input.empty?
    # Extract creation date from video metadata
    cmd = %Q(ffprobe -v quiet -print_format json -show_format "#{video}")
    metadata_json = `#{cmd}`
    begin
      metadata = JSON.parse(metadata_json)
      creation_time = metadata.dig('format', 'tags', 'creation_time')

      if creation_time
        date = Time.parse(creation_time)
        day = date.day
        month = date.month
        year = date.year
        puts "📅 Using file metadata date: #{date.strftime('%Y-%m-%d')}"
      else
        puts "⚠️  No creation date found in metadata, using today's date"
        date = Time.now
        day = date.day
        month = date.month
        year = date.year
      end
    rescue => e
      puts "⚠️  Error reading metadata: #{e.message}. Using today's date"
      date = Time.now
      day = date.day
      month = date.month
      year = date.year
    end
  else
    # Use manual input
    day = input.to_i until day&.between?(1, 31)
    puts "⚠️  Please enter a valid day (1-31)" unless day.between?(1, 31)

    month = nil
    until month&.between?(1, 12)
      print "Month (1-12): "
      month = STDIN.gets.chomp.to_i
      puts "⚠️  Please enter a valid month (1-12)" unless month.between?(1, 12)
    end

    current_year = Time.now.year
    year = nil
    until year&.between?(1900, current_year)
      print "Year (YYYY): "
      year = STDIN.gets.chomp.to_i
      puts "⚠️  Please enter a valid year (1900-#{current_year})" unless year.between?(1900, current_year)
    end
  end

  formatted_date = Time.new(year, month, day, 12, 0, 0, 'UTC').strftime('%Y-%m-%dT%H:%M:%SZ')

  # Handle thumbnail
  print "🖼  Add thumbnail? (y/N): "
  if STDIN.gets.chomp.downcase == 'y'
    print "Enter path to thumbnail image: "
    thumb_path = STDIN.gets.chomp
    if File.exist?(thumb_path)
      FileUtils.mv(thumb_path, File.join(folder_path, "thumbnail.png"))
    else
      puts "⚠️  Thumbnail file not found, skipping thumbnail..."
    end
  end

  # Generate thumbnail if none provided
  unless File.exist?(File.join(folder_path, "thumbnail.png"))
    puts "📸 Generating thumbnail from video..."
    system("ffmpeg -i \"#{video}\" -vf \"select=gt(scene\\,0.4)\" -frames:v 1 -vsync vfr \"#{folder_path}/thumbnail.png\" -y 2>/dev/null")
    puts "✅ Generated thumbnail using scene detection"
  end

  # Create metadata.json
  metadata = {
    title: title,
    description: description,
    created_at: formatted_date,
    tags: tags.split(',').map(&:strip).reject(&:empty?)
  }

  File.write(File.join(folder_path, "metadata.json"), JSON.pretty_generate(metadata))

  # Move video file
  FileUtils.mv(video, File.join(folder_path, "original.mp4"))

  puts "\n✅ Created folder #{folder_num} with:"
  system("ls -la \"#{folder_path}\"")

  count += 1
end

puts "\n🎉 Processing complete!"
puts "Files organized in: #{BASE_DIR}"
