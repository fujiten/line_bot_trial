class Replier
  attr_accessor :request, :request_body

  def initialize(request)
    @request = request
    @request_body = request.body.read
  end

  def validate_of(request)
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    client.validate_signature(request_body, signature)
  end

  def reply_message_according_to(request_body)
    events = client.parse_events_from(request_body)
    text_params = events[0]["message"]["text"]
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          if text_params =~ /天気/





            whether = Whether.new
            url = "http://weather.livedoor.com/forecast/webservice/json/v1?city=130010"
            hash_response = whether.fetch_whether_from(url)
            whether.set_todays_whether(hash_response)
            message = {
              type: 'text',
              text: "#{whether.datelabel}の天気は#{whether.telop}です。"
            }
            client.reply_message(event['replyToken'], message)
          elsif text_params =~ /ニュース/
            news = News.new
            news_info = news.fetch_top_access_of_news
            message = {
              type: 'text',
              text: "今日のトップニュースは「#{news_info[:title]}」です。
              詳細は#{news_info[:link]}へどうぞ。（情報元：#{news_info[:source]}）"
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
  end

  private

  def client
    client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

end
