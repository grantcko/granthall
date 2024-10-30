require 'json'
require 'time'
require 'readline'

# Directory containing the numbered folders
base_dir = '/Users/granthall/Downloads/tmp_1030'

# Process each numbered directory
Dir.glob(File.join(base_dir, '*')).sort.each do |dir|
  metadata_file = File.join(dir, 'metadata.json')
  next unless File.exist?(metadata_file)

  # Read existing metadata
  metadata = JSON.parse(File.read(metadata_file))

  while true
    # Display title and current date
    puts "\nVideo: #{metadata['title']}"
    puts "Current date: #{metadata['created_at']}"

    # Use Readline instead of gets for proper backspace handling
    input = Readline.readline("Enter month and year (MM YYYY), 'skip', or 'delete': ", true).to_s.downcase

    case input
    when 'skip'
      puts "Skipping #{metadata['title']}..."
      break
    when 'delete'
      if File.exist?(metadata_file)
        File.delete(metadata_file)
        puts "Deleted metadata for #{metadata['title']}"
      end
      break
    when ''
      puts "Skipping #{metadata['title']}..."
      break
    else
      begin
        month, year = input.split
        if month && year
          # Create new date (setting it to the 1st of the month)
          new_date = Time.new(year.to_i, month.to_i, 1, 12, 0, 0).utc.strftime("%Y-%m-%dT%H:%M:%SZ")

          # Update the created_at field
          metadata['created_at'] = new_date

          # Write the updated metadata back to file
          File.write(metadata_file, JSON.pretty_generate(metadata))

          puts "Updated #{metadata['title']} to #{new_date}"
          break
        else
          puts "Invalid input format. Please use 'MM YYYY' (e.g., '05 2019')"
        end
      rescue ArgumentError => e
        puts "Invalid date. Please try again."
      end
    end
  end
end

puts "\nAll metadata files have been processed!"
