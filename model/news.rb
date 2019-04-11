require 'mechanize'

class News
  attr_accessor :text_params

  def initialize(text_params)
    @text_params = text_params
  end

  def create_message
    news_info = fetch_top_access_of_news
    message = {
      type: 'text',
      text: "今日のトップニュースは「#{news_info[:title]}」です。\n詳細:#{news_info[:link]} \n（情報元：#{news_info[:source]}）",
      quickReply: create_quick_reply_object
    }
  end


  private

  def fetch_top_access_of_news
    news = {}
    agent = Mechanize.new
    page = agent.get('https://news.yahoo.co.jp/')
    elements = page.at('.yjnSub_list_item a')
    link = elements.get_attribute('href')
    title = elements.at('.yjnSub_list_headline').inner_text
    source = elements.at('.yjnSub_list_sub_media').inner_text
    news[:link] = link
    news[:title] = title
    news[:source] = source
    news
  end

  def create_quick_reply_object
    {
      items: [
        {
          type: "action",
          action: {
            type: "message",
            label: "戻る",
            text: "初期状態に戻りたい"
          }
        }
      ]
    }
  end



end
