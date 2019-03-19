require 'mechanize'

class News

  def fetch_top_access_of_news
    news = {}
    agent = Mechanize.new
    page = agent.get('https://news.yahoo.co.jp/')
    elements = page.at('.yjnSub_list_wrap a')
    link = elements.get_attribute('href')
    title = elements.at('.yjnSub_list_head').inner_text
    source = elements.at('.yjnSub_list_source span').inner_text
    news[:link] = link
    news[:title] = title
    news[:source] = source
    news
  end

end
