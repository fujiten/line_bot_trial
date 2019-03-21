require 'sinatra'
require "sinatra/activerecord"
require "sinatra/reloader" if development?
require 'pry-byebug'
require 'line/bot'
require 'pg'
require './model/application_model'

# set :database, {adapter: "postgresql", }

configure :development do
  set :database, {adapter: 'postgresql', database: "line_bot_development"}
end

configure :production do
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
end

# ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] )

post '/callback' do

  #本番環境ではコメントアウトする
  load "./model/replier.rb"
  load "./model/whether.rb"

  replier = Replier.new(request)

  unless replier.validate_of(replier.request)
    error 400 do 'Bad Request' end
  end

  replier.reply_message_according_to(replier.request_body)
  'OK'
end

get '/whether' do

  city = City.find(3)
  city.name
end
