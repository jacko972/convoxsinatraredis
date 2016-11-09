# frozen_string_literal: true

require 'redis'
require 'sinatra/base'
require 'sinatra/reloader'
require 'json'

RedisClient = Redis.new(url: ENV['CACHE_URL'])

QUEUE = 'convox.queue'
MESSAGES = 'convox.messages'
APP_NAME = 'webapp'

# Web < Sinatra::Base
class Web < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  set :erb, escape_html: true

  get '/' do
    msgs = RedisClient.lrange(MESSAGES, 0, -1)
    puts "connected at #{ENV['CACHE_URL']} - there are #{msgs.count} messages"
    pmsgs = msgs.map do |m|
      begin
        puts m
        JSON.parse(m)
      rescue StandardError => e
        { text: "error: #{e}", error: 1 }
      end
    end
    puts "messages retrieved: #{pmsgs}"
    erb :index, locals: { messages: pmsgs }
  end

  get '/check' do
    fmt = 'OK : %s connected at %s'
    puts(format(fmt, APP_NAME, ENV['CACHE_URL']))
    'OK'
  end

  post '/message' do
    fmt = 'message received: %s and pushing into %s:%s'
    puts(format(fmt, params, ENV['CACHE_URL'], QUEUE))
    RedisClient.lpush(QUEUE, params['text'])
    redirect to('/')
  end
end
