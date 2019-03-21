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
    user = create_or_find_user_from(events)

    text_params = events[0]["message"]["text"]

    if text_params =~ /戻る/
      user.status = "0"
      user.save
      message = {
        type: 'text',
        text: "[状態：待機]\n待機状態に戻るね。"
      }
      client.reply_message(events[0]['replyToken'], message)
    end


    status = user.status

    if status == "天気"
      city = City.where('name LIKE ?', "%#{text_params}%")
      if city.empty?
        message = {
          type: 'text',
          text: "[状態：解読不能]\nごめん、市町村名だけで教えてくれない？ 例えば「大阪」みたいに。"
        }
        client.reply_message(events[0]['replyToken'], message)
      else
        message = Whether.create_message_about_whether_in(city[0])
        client.reply_message(events[0]['replyToken'], message)
      end
    end



    if status == "0"
      events.each { |event|
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            if text_params =~ /天気/
              status = "天気"
              user.status = status
              user.save
              message = {
                type: 'text',
                text: "[対話状態：天気] \n今日の天気を教えてあげるよ。聞いてみて？"
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
                text: "[状態：待機]\n" + event.message['text'] + "…って、どういう意味？" + user.name
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

  end

  private

  def client
    client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def create_or_find_user_from(events)
    user_id = events[0]["source"]["userId"]
    user = User.find_by(uid: user_id)
    unless user
      user = User.new(uid: user_id)
      if user.save
        user
      else
        #エラー時の処理は後に書く. 今は"400"を返しておく
        user = "400"
      end
    end
    user
  end

end
