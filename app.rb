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

  load "./model/brain.rb"
  brain = Brain.new("こんにちは、明日の大阪はどんな日になるだろう")
  word = brain.generate_analized_array_words
  word.inspect

end
