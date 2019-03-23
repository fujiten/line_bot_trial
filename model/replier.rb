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
      analized_words = generate_analized_words_from(text_params)
      region_arr = extract_region_word_from(analized_words)

      if region_arr.empty?
        message = {
          type: 'text',
          text: "[状態：天気検索]\n「大阪」みたいに地域名を教えてほしいんだ。興味ないなら「戻る」って言ってね。"
        }
      elsif region_arr.length > 1
        message = {
          type: 'text',
          text: "[エラー：複数の地域]\n一度にたくさんの地域を言われると分析できないんだよね。気を使ってほしいな。"
        }
      else
        city = City.find_by(name: region_arr[0])
        if city.nil?
          message = {
            type: 'text',
            text: "[エラー：サポート範囲外]\n#{region_arr[0]}の天気はちょっとわかんないなあ…。ごめんね。"
          }
        else
          message = Whether.create_message_about_whether_in(city)
        end
      end
      client.reply_message(events[0]['replyToken'], message)
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
                text: "[状態：天気検索] \n今日の天気を調べるよ。知りたい場所を入力してみて。"
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
                text: "[状態：待機中]\n" + event.message['text'] + "…って、どういう意味？"
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

  def generate_analized_words_from(text)
    arr = []
    natto = Natto::MeCab.new
    natto.parse(text) do |n|
      arr << {n.surface => n.feature.split(",")}
    end
    arr
  end

  def extract_region_word_from(text_array)
    region_arr = []

    text_array.each do |hash|
      hash.each do |k, v|
        if v[2] == "地域"
          region_arr << k
        end
      end
    end
    region_arr
  end

end
