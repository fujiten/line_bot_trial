class Users < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
    t.string :uid
    t.string :status, default: 0
    t.string :name, default: 'ご新規さん'
    end
  end
end
