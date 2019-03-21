require 'sinatra'
require "sinatra/activerecord"
require "sinatra/reloader" if development?
require 'pry-byebug'
require 'line/bot'
require 'pg'
require './model/application_model'

set :database, {adapter: "postgresql", database: "line_bot_development"}

post '/callback' do

  #本番環境では削除する
  load "./model/replier.rb"

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
