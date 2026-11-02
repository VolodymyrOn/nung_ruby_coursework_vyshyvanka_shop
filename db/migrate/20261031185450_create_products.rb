class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :title
      t.text :description
      t.string :fabric
      t.string :color
      t.string :technique
      t.string :target_group
      t.references :category, null: false, foreign_key: true
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :stock_s, default: 0, null: false
      t.integer :stock_m, default: 0, null: false
      t.integer :stock_l, default: 0, null: false
      t.integer :stock_xl, default: 0, null: false
      t.integer :stock_2xl, default: 0, null: false
      t.boolean :is_active, default: true, null: false

      t.timestamps
    end
  end
end
