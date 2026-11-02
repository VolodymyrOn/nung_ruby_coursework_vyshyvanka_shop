class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :product_title, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.string :size
      t.integer :quantity

      t.timestamps
    end
  end
end
