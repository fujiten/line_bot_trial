require 'sinatra'
require "sinatra/activerecord"
require "sinatra/reloader" if development?
require 'pry-byebug'
require 'line/bot'
require 'pg'
require './model/application_model'
require 'natto'

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
  load "./model/news.rb"
  load "./model/battle_choice.rb"

  replier = Replier.new(request)

  unless replier.validate_of(replier.request)
    error 400 do 'Bad Request' end
  end

  replier.reply_message_according_to(replier.request_body)
  'OK'
end

get '/whether' do

  word = "東京と大阪では静岡形態素解析を旭川と行った研究は当たり前だよ。ニューヨーク"
  arr = []

  natto = Natto::MeCab.new
  natto.parse(word) do |n|
    arr << {n.surface => n.feature.split(",")}
  end

  region_arr = []

  arr.each do |hash|
    hash.each do |k, v|
      if v[2] == "地域"
        word << k
      end
    end
  end
  region_arr

end
