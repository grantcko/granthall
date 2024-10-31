require 'bundler/setup'
require 'dotenv/load'
require 'aws-sdk-mediaconvert'

# Get job ID from command line argument
job_id = ARGV[0]
if job_id.nil? || job_id.empty?
  puts "❌ Please provide a job ID"
  puts "Usage: ruby scripts/check_mediaconvert_job.rb <job_id>"
  exit 1
end

puts "🎥 MediaConvert Job Status"
puts "========================="
puts "Job ID: #{job_id}"

begin
  # Create MediaConvert client
  client = Aws::MediaConvert::Client.new(
    region: ENV['AWS_REGION'],
    endpoint: ENV['MEDIACONVERT_ENDPOINT']
  )

  # Get job details
  response = client.get_job(id: job_id)
  job = response.job

  # Print job status
  status = job.status
  status_emoji = case status
                 when "SUBMITTED" then "📨"
                 when "PROGRESSING" then "⚙️ "
                 when "COMPLETE" then "✅"
                 when "ERROR" then "❌"
                 else "❓"
                 end

  puts "\nStatus: #{status_emoji} #{status}"

  if status == "PROGRESSING"
    # Show progress percentage if available
    progress = job.current_phase == "TRANSCODING" ? job.job_percent_complete : 0
    puts "Progress: #{progress}%"
    puts "Current Phase: #{job.current_phase}"
  end

  if status == "COMPLETE"
    puts "\nOutput Files:"
    puts "s3://#{ENV['AWS_BUCKET_NAME']}/#{job.settings.output_groups[0].output_group_settings.hls_group_settings.destination.split('/')[-3..-1].join('/')}"
  end

  if status == "ERROR"
    puts "\nError Message:"
    puts job.error_message
    puts "\nError Code:"
    puts job.error_code
  end

  # Show job timing
  puts "\nTiming:"
  puts "Submitted: #{job.timing.submit_time}"
  puts "Started: #{job.timing.start_time}" if job.timing.start_time
  puts "Finished: #{job.timing.finish_time}" if job.timing.finish_time

  if job.timing.finish_time && job.timing.start_time
    duration = (job.timing.finish_time - job.timing.start_time).to_i
    puts "Duration: #{duration} seconds"
  end

  # Show billing details if job is complete
  if status == "COMPLETE"
    puts "\nBilling:"
    puts "Queue: #{job.queue}"
    puts "Priority: #{job.current_phase}"
    puts "Acceleration: #{job.acceleration_settings ? 'Enabled' : 'Disabled'}"
    puts "User Metadata: #{job.user_metadata}"
  end

rescue Aws::MediaConvert::Errors::ServiceError => e
  puts "\n❌ Error: #{e.message}"
  exit 1
end
