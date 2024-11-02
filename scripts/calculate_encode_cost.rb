#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'dotenv/load'

BUNNY_API = "https://video.bunnycdn.com/library/#{ENV['BUNNY_LIBRARY_ID']}/videos"
HEADERS = {
  "AccessKey" => ENV['BUNNY_API_KEY'],
  "accept" => "application/json"
}

# Price rates per minute based on resolution
PRICES = {
  'SD' => 0.025,   # 480p and below
  'HD' => 0.050,   # 1080p and 720p
  '4K' => 0.150    # Above 1080p
}

# Streaming costs per GB
STREAM_PRICES = {
  'standard' => 0.005,  # Standard Stream per GB
  'volume' => 0.004,    # Volume Stream per GB
  'premium' => 0.015    # Premium Stream per GB
}

# Delivery/CDN costs per GB
DELIVERY_PRICES = {
  'standard' => 0.01,    # Standard delivery per GB
  'volume' => 0.005,     # Volume delivery per GB
  'high_volume' => 0.004 # High Volume delivery per GB
}

# Estimated GB per minute of streaming for different resolutions
GB_PER_MINUTE = {
  'SD' => 0.035,   # ~35MB per minute
  'HD' => 0.110,   # ~110MB per minute
  '4K' => 0.375    # ~375MB per minute
}

def calculate_encode_cost(duration_seconds, resolution)
  duration_minutes = duration_seconds / 60.0
  cost = duration_minutes * PRICES[resolution]
  cost.round(2)
end

def calculate_stream_cost(duration_seconds, resolution)
  duration_minutes = duration_seconds / 60.0
  gb_size = duration_minutes * GB_PER_MINUTE[resolution]
  {
    'standard' => (gb_size * STREAM_PRICES['standard']).round(2),
    'volume' => (gb_size * STREAM_PRICES['volume']).round(2),
    'premium' => (gb_size * STREAM_PRICES['premium']).round(2)
  }
end

def calculate_delivery_cost(gb_size)
  {
    'standard' => (gb_size * DELIVERY_PRICES['standard']).round(2),
    'volume' => (gb_size * DELIVERY_PRICES['volume']).round(2),
    'high_volume' => (gb_size * DELIVERY_PRICES['high_volume']).round(2)
  }
end

def get_resolution_tier(height)
  case height
  when 0..480
    'SD'
  when 481..1080
    'HD'
  else
    '4K'
  end
end

begin
  puts "📊 Calculating encoding, streaming, and delivery costs..."

  response = HTTParty.get(BUNNY_API, headers: HEADERS)

  if response.success?
    videos = response.parsed_response['items']
    total_encode_cost = 0
    total_standard_stream_cost = 0
    total_volume_stream_cost = 0
    total_premium_stream_cost = 0
    total_standard_delivery_cost = 0
    total_volume_delivery_cost = 0
    total_high_volume_delivery_cost = 0
    total_duration = 0
    total_gb = 0

    puts "\nBreakdown by video:"
    puts "=" * 70

    videos.each do |video|
      duration = video['length']
      height = video['height'] || 1080
      resolution = get_resolution_tier(height)
      encode_cost = calculate_encode_cost(duration, resolution)
      stream_costs = calculate_stream_cost(duration, resolution)
      gb_size = (duration / 60.0) * GB_PER_MINUTE[resolution]
      delivery_costs = calculate_delivery_cost(gb_size)

      total_encode_cost += encode_cost
      total_standard_stream_cost += stream_costs['standard']
      total_volume_stream_cost += stream_costs['volume']
      total_premium_stream_cost += stream_costs['premium']
      total_standard_delivery_cost += delivery_costs['standard']
      total_volume_delivery_cost += delivery_costs['volume']
      total_high_volume_delivery_cost += delivery_costs['high_volume']
      total_duration += duration
      total_gb += gb_size

      puts "#{video['title']}"
      puts "  Duration: #{duration} seconds (#{(duration/60.0).round(2)} minutes)"
      puts "  Resolution: #{resolution} (#{height}p)"
      puts "  Estimated Size: #{gb_size.round(2)} GB"
      puts "  Encoding Cost: $#{encode_cost}"
      puts "  Streaming Costs:"
      puts "    Standard: $#{stream_costs['standard']}"
      puts "    Volume: $#{stream_costs['volume']}"
      puts "    Premium: $#{stream_costs['premium']}"
      puts "  Delivery Costs:"
      puts "    Standard: $#{delivery_costs['standard']}"
      puts "    Volume: $#{delivery_costs['volume']}"
      puts "    High Volume: $#{delivery_costs['high_volume']}"
      puts "-" * 70
    end

    puts "\nSummary:"
    puts "Total Duration: #{total_duration} seconds (#{(total_duration/60.0).round(2)} minutes)"
    puts "Total Estimated Size: #{total_gb.round(2)} GB"
    puts "\nBreakdown of Costs:"
    puts "  Encoding: $#{total_encode_cost.round(2)}"
    puts "  Streaming (per tier):"
    puts "    Standard: $#{total_standard_stream_cost.round(2)}"
    puts "    Volume: $#{total_volume_stream_cost.round(2)}"
    puts "    Premium: $#{total_premium_stream_cost.round(2)}"
    puts "  Delivery (per tier):"
    puts "    Standard: $#{total_standard_delivery_cost.round(2)}"
    puts "    Volume: $#{total_volume_delivery_cost.round(2)}"
    puts "    High Volume: $#{total_high_volume_delivery_cost.round(2)}"
    puts "\nTotal Cost Estimates (Encoding + Streaming + Delivery):"
    puts "  Standard Tier: $#{(total_encode_cost + total_standard_stream_cost + total_standard_delivery_cost).round(2)}"
    puts "  Volume Tier: $#{(total_encode_cost + total_volume_stream_cost + total_volume_delivery_cost).round(2)}"
    puts "  Premium/High Volume Tier: $#{(total_encode_cost + total_premium_stream_cost + total_high_volume_delivery_cost).round(2)}"

  else
    puts "❌ Failed to fetch videos: #{response.code} - #{response.body}"
    exit 1
  end

rescue StandardError => e
  puts "❌ Error: #{e.message}"
  exit 1
end
