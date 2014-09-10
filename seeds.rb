require 'json'
require 'redis'

$redis = Redis.new(url: ENV["REDISTOGO_URL"])

# Clear out any old data
$redis.flushdb

# Create a counter to track indexes
$redis.set("message:index", 0)

puts "Seeded db ..."
