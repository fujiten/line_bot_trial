require 'sinatra'
require "sinatra/activerecord"
require 'pry-byebug'
require 'line/bot'
require 'pg'
require './model/application_model'


set :database, {adapter: "postgresql", database: "line_bot_development"}



def fetch_rainy_percent_of_osaka
  agent = Mechanize.new
  page = agent.get('https://tenki.jp/forecast/6/30/6200/27100/')
  elements = page.search('.rain-probability td').inner_text
  string_array = elements.split('%')
  probability_array = string_array.map{ |s| s[/\d+/] }
  probability_array[1].to_i
end




post '/callback' do
  replier = Replier.new(request)
  unless replier.validate_of(replier.request)
    error 400 do 'Bad Request' end
  end
  replier.reply_message_according_to(replier.request_body)
  'OK'
end
