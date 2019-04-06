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

  private

  def create_plain_message
    message = { type: 'text',
                text: "[状態：待機中]\n#{text_params}…って、どういう意味？",
                quickReply: BattleChoice.create_quick_reply_object
              }
  end
end
