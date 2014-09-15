require 'json'
require 'redis'

$redis = Redis.new(url: ENV["REDISTOGO_URL"])

$redis.flushdb

$redis.set("message:index", 0)

puts "Seeded db ..."
