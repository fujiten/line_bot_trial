require './model/city'

lambda {
  numbers = ["011000", "012010", "012020", "013010", "013020", "013030", "014010", "014020", "014030", "015010", "015020", "016010", "016020", "016030", "017010", "017020", "020010", "020020", "020030", "030010", "030020", "030030", "040010", "040020", "050010", "050020", "060010", "060020", "060030", "060040", "070010", "070020", "070030", "080010", "080020", "090010", "090020", "100010", "100020", "110010", "110020", "110030", "120010", "120020", "120030", "130010", "130020", "130030", "130040", "140010", "140020", "150010", "150020", "150030", "150040", "160010", "160020", "170010", "170020", "180010", "180020", "190010", "190020", "200010", "200020", "200030", "210010", "210020", "220010", "220020", "220030", "220040", "230010", "230020", "240010", "240020", "250010", "250020", "260010", "260020", "270000", "280010", "280020", "290010", "290020", "300010", "300020", "310010", "310020", "320010", "320020", "320030", "330010", "330020", "340010", "340020", "350010", "350020", "350030", "350040", "360010", "360020", "370000", "380010", "380020", "380030", "390010", "390020", "390030", "400010", "400020", "400030", "400040", "410010", "410020", "420010", "420020", "420030", "420040", "430010", "430020", "430030", "430040", "440010", "440020", "440030", "440040", "450010", "450020", "450030", "450040", "460010", "460020", "460030", "460040", "471010", "471020", "471030", "472000", "473000", "474010", "474020"]

  cities = ["稚内", "旭川", "留萌", "網走", "北見", "紋別", "根室", "釧路", "帯広", "室蘭", "浦河", "札幌", "岩見沢", "倶知安", "函館", "江差", "青森", "むつ", "八戸", "盛岡", "宮古", "大船渡", "仙台", "白石", "秋田", "横手", "山形", "米沢", "酒田", "新庄", "福島", "小名浜", "若松", "水戸", "土浦", "宇都宮", "大田原", "前橋", "みなかみ", "さいたま", "熊谷", "秩父", "千葉", "銚子", "館山", "東京", "大島", "八丈島", "父島", "横浜", "小田原", "新潟", "長岡", "高田", "相川", "富山", "伏木", "金沢", "輪島", "福井", "敦賀", "甲府", "河口湖", "長野", "松本", "飯田", "岐阜", "高山", "静岡", "網代", "三島", "浜松", "名古屋", "豊橋", "津", "尾鷲", "大津", "彦根", "京都", "舞鶴", "大阪", "神戸", "豊岡", "奈良", "風屋", "和歌山", "潮岬", "鳥取", "米子", "松江", "浜田", "西郷", "岡山", "津山", "広島", "庄原", "下関", "山口", "柳井", "萩", "徳島", "日和佐", "高松", "松山", "新居浜", "宇和島", "高知", "室戸岬", "清水", "福岡", "八幡", "飯塚", "久留米", "佐賀", "伊万里", "長崎", "佐世保", "厳原", "福江", "熊本", "阿蘇乙姫", "牛深", "人吉", "大分", "中津", "日田", "佐伯", "宮崎", "延岡", "都城", "高千穂", "鹿児島", "鹿屋", "種子島", "名瀬", "那覇", "名護", "久米島", "南大東", "宮古島", "石垣島", "与那国島"]

  numbers.each_with_index do |num, i|
    City.create(name: "#{cities[i]}", string_number: num )
  end
}.call