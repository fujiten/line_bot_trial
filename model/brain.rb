class Brain
  attr_accessor :text

  def initialize(text)
    @text = text
  end

  def generate_analized_array_words
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
