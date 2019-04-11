require 'uri'
require 'net/http'
require 'json'

class Whether
  attr_accessor :text_params, :datelabel, :telop

  def initialize(text_params)
    @text_params = text_params
  end


  def create_message
    analized_words = generate_analized_array_words
    region_arr = extract_region_word_from(analized_words)

    if region_arr.empty?
      message = {
        type: 'text',
        text: "[状態：天気検索]\n「東京」みたいに地域名を入力してください。興味ないなら「戻る」って言ってね。"
      }
    elsif region_arr.length > 1
      message = {
        type: 'text',
        text: "[エラー：複数の地域]\n一度にたくさんの地域を言われると分析できないんだよね。気を使ってほしいな。"
      }
    else
      city_instance = City.find_by(name: region_arr[0])
      if city_instance.nil?
        message = {
          type: 'text',
          text: "[エラー：サポート範囲外]\n#{region_arr[0]}の天気はちょっとわかんないなあ…。ごめんね。"
        }
      else
        message = search_whether_in(city_instance)
      end
    end
  end

  def search_whether_in(city)
    url = "http://weather.livedoor.com/forecast/webservice/json/v1?city=#{city.string_number}"
    hash_response = Whether.fetch_whether_from(url)
    set_todays_whether(hash_response)
    message = {
      type: 'text',
      text: "[状態：天気検索]\n#{city.name}の#{datelabel}の天気は#{telop}だよ。"
    }
  end

  def self.fetch_whether_from(url)
    uri = URI.parse(url)
    res = Net::HTTP.get(uri)
    hash_res = JSON.parse(res)
  end

  private

  def set_todays_whether(response)
    three_days_whether = response["forecasts"]
    today_whether = three_days_whether[0]
    @datelabel = today_whether["dateLabel"]
    @telop = today_whether["telop"]
  end

  def generate_analized_array_words
    arr = []
    natto = Natto::MeCab.new
    natto.parse(text_params) do |n|
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

# whether = Whether.new
# url = "http://weather.livedoor.com/forecast/webservice/json/v1?city=130010"
# hash_response = whether.fetch_whether_from(url)
# whether.set_todays_whether(hash_response)
# puts whether.telop
# puts whether.datelabel
