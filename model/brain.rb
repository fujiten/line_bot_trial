class Brain
  attr_accessor :user, :events, :text_params, :postback_params

  def initialize(user: User.new, events: events)
    @user = user
    @events = events
    @postback_params = events[0]["postback"]
    @text_params = events[0]["message"]["text"] unless @postback_params
  end

  def delegate_to_class_to_create_message
    status = user.status
    if status == "0"
      create_plain_message
    else
      delegated_class = Object.const_get(status.capitalize)
      delegated_object = delegated_class.new(text_params)
      delegated_object.create_message
    end
  end

  def set_user_status
    if user.status == "0"
      update_user('whether')  if text_params.match?(/天気/)
      update_user('fight')    if text_params.match?(/RPG/)
      update_user('news')     if text_params.match?(/ニュース/)
    end
    update_user('0')        if text_params.match?(/戻/)
  end

  private

  def update_user(status)
    user.status = status
    user.save
  end

  def create_plain_message
    message = { type: 'text',
                text: "[状態：待機中]\n#{text_params}…わかった。待機するね",
                quickReply: create_quick_reply_object
              }
  end

  def create_quick_reply_object
    {
      items: [
        {
          type: "action",
          action: {
            type: "message",
            label: "天気",
            text: "今日の天気が気になる"
          }
        },
        {
          type: "action",
          action: {
            type: "message",
            label: "ニュース",
            text: "話題のニュースを教えて"
          }
        },
        {
          type: "action",
          action: {
            type: "message",
            label: "ゲーム",
            text: "RPGゲームで遊びたい"
          }
        },
        {
          type: "action",
          action: {
            type: "message",
            label: "雑談",
            text: "暇つぶしに付き合ってよ"
          }
        }
      ]
    }
  end

end
