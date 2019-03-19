require 'uri'
require 'net/http'
require 'json'

class Whether
  attr_accessor :datelabel, :telop

  def fetch_whether_from(url)
    uri = URI.parse(url)
    res = Net::HTTP.get(uri)
    hash_res = JSON.parse(res)
  end

  def set_todays_whether(response)
    three_days_whether = response["forecasts"]
    today_whether = three_days_whether[0]
    @datelabel = today_whether["dateLabel"]
    @telop = today_whether["telop"]
  end



end

# whether = Whether.new
# url = "http://weather.livedoor.com/forecast/webservice/json/v1?city=130010"
# hash_response = whether.fetch_whether_from(url)
# whether.set_todays_whether(hash_response)
# puts whether.telop
# puts whether.datelabel
