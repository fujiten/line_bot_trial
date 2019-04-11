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
