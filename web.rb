# frozen_string_literal: true

require 'redis'
require 'sinatra/base'
require 'sinatra/reloader'
require 'json'

RedisClient = Redis.new(url: ENV['REDIS_URL'])

QUEUE = 'convox.queue'
MESSAGES = 'convox.messages'

# Web < Sinatra::Base
class Web < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  set :erb, escape_html: true

  get '/' do
    msgs = RedisClient.lrange(MESSAGES, 0, -1)
    puts "there are #{msgs.count} messages"
    msgs.map do |m|
      begin
        puts m
        JSON.parse(m)
      rescue StandardError => e
        { text: "error: #{e}", error: 1 }
      end
    end
    puts "messages retrieved: #{msgs}"
    erb :index, locals: { messages: msgs }
  end

  get '/check' do
    'ok'
  end

  post '/message' do
    puts "message received: #{params.inspect} and pushing into #{QUEUE}"
    RedisClient.lpush(QUEUE, params['text'])
    redirect to('/')
  end
end
