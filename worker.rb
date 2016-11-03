# frozen_string_literal: true

require 'redis'
require 'json'

RedisClient = Redis.new(url: ENV['REDISCLIENT_URL'])

QUEUE = 'convox.queue'
MESSAGES = 'convox.messages'

loop do
  puts 'working on it'
  list, text = RedisClient.blpop(QUEUE, timeout: 5)
  next unless list == QUEUE
  puts "message popped out: #{[:text, text]}"
  RedisClient.lpush(MESSAGES, { text: text, created_at: DateTime.now }.to_json)
end
