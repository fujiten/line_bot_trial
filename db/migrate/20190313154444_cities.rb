class Cities < ActiveRecord::Migration[5.2]
  def change
    create_table :cities do |t|
    t.string :name
    t.string :string_number
    end
  end
end
