class Fight
  attr_accessor :text_params

  def initialize(text_params)
    @text_params = text_params
  end

  def create_message
    message = {
      type: 'text',
      text: "[状態：戦闘中]\n#{text_params}…？私には効かんなあ！",
      quickReply: BattleChoice.create_quick_reply_object
    }
  end

end
