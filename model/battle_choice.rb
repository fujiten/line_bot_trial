class BattleChoice

  def self.create_quick_reply_object
    {
      items: [
        {
          type: "action",
          imageUrl: "https://www.silhouette-illust.com/wp-content/uploads/2017/05/buki_tsurugi_30115-300x300.jpg",
          action: {
            type: "message",
            label: "こうげき",
            text: "振りかぶって剣を振る！"
          }
        },
        {
          type: "action",
          imageUrl: "https://www.silhouette-illust.com/wp-content/uploads/2016/06/3622-300x300.jpg",
          action: {
            type: "message",
            label: "じゅもん",
            text: "MPを使い、魔法をとなえる！"
          }
        },
        {
          type: "action",
          imageUrl: "https://www.silhouette-illust.com/wp-content/uploads/2016/08/8653-300x300.jpg",
          action: {
            type: "message",
            label: "かいふく",
            text: "MPを使い、回復する！"
          }
        },
        {
          type: "action",
          imageUrl: "https://www.silhouette-illust.com/wp-content/uploads/2017/07/olympic_seika-runner_35150-300x300.jpg",
          action: {
            type: "message",
            label: "にげる",
            text: "ぜんそくりょくで後ろに走り出す！"
          }
        }
      ]
    }
  end
end
