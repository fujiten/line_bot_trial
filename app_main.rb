require 'sinatra'
require 'pry-byebug'
require 'line/bot'
require 'mechanize'




def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

def fetch_rainy_percent_of_osaka
  agent = Mechanize.new
  page = agent.get('https://tenki.jp/forecast/6/30/6200/27100/')
  elements = page.search('.rain-probability td').inner_text
  string_array = elements.split('%')
  probability_array = string_array.map{ |s| s[/\d+/] }
  probability_array[1].to_i
end

get '/' do
  if rainy = fetch_rainy_percent_of_osaka > 40
    push_content = {
      type: 'text',
      text: "明日の降水確率は#{rainy}%です。傘を持っていったほうがいいかもね。",
    }
  else
    push_content = {
      type: 'text',
      text: "明日の降水確率は#{rainy}%です。傘はいらなそうだね。",
    }
    user_id = "U1ccc5e7afdc77a70d9d7b7fb52235091"
    response = client.push_message(user_id, push_content)
  end
end


post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  text_params = events[0]["message"]["text"]
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        if text_params =~ /天気/
          message = {
            type: 'text',
            text: "明日の降水確率は#{fetch_rainy_percent_of_osaka}%です。"
          }
          client.reply_message(event['replyToken'], message)
        else
          message = {
            type: 'text',
            text: event.message['text'] + "…って、どういう意味ですか？"
          }
          client.reply_message(event['replyToken'], message)
        end
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end
    end
  }
  "OK"
end
