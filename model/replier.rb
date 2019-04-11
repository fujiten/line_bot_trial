class Replier
  attr_accessor :request, :client, :request_body,
                :user, :events, :text_params, :postback_params

  def initialize(request)
    @request = request
    @client ||= set_client
    @request_body = request.body.read
    @events = client.parse_events_from(request_body)
    @user = create_or_find_user_from(events)
    @postback_params ||= events[0]["postback"]
    @text_params ||= events[0]["message"]["text"] unless @postback_params
  end

  def validate_of(request)
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    client.validate_signature(request_body, signature)
  end

  def reply(message)
    client.reply_message(events[0]['replyToken'], message)
  end

  def reply_message

    if postback_params
      data_params = postback_params["data"]
      if data_params == 'たたかう'
        user.status = "fighting"
        user.save
        message = {
          type: 'text',
          text: "[状態：戦闘開始！]",
          quickReply: BattleChoice.create_quick_reply_object
        }
        client.reply_message(events[0]['replyToken'], message)
        binding.pry
      elsif data_params == 'にげる'
      end

    else

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

      if status == "whether"
        whether = Whether.new(text_params)
        message = whether.create_message
        client.reply_message(events[0]['replyToken'], message)
      end

      if status == "fighting"
        message = {
          type: 'text',
          text: "[状態：戦闘中]\n#{text_params}…？私には効かんなあ！",
          quickReply: BattleChoice.create_quick_reply_object
        }
        client.reply_message(events[0]['replyToken'], message)
      end


      if status == "0"
        if text_params =~ /スライム/
          template = {
            type: 'buttons',
            text: 'スライムがあらわれた！',
            thumbnailImageUrl: 'https://item-shopping.c.yimg.jp/i/j/fishingcat_5958',
            actions: [
                       { type: "postback", label: 'たたかう', data: 'たたかう' },
                       { type: 'postback', label: 'にげる',  data: 'にげる' }
                       ]
            }
          message = {
            type: 'template',
            altText: '代替テキスト',
            template: template
          }
        end
        client.reply_message(events[0]['replyToken'], message)
      end
    end


  end

  private

  def set_client
    Line::Bot::Client.new { |config|
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
