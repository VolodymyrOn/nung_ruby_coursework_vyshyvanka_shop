class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, default: "pending", null: false
      t.decimal :total_amount, precision: 10, scale: 2, default: 0, null: false
      t.string :delivery_method
      t.text :delivery_address
      t.string :payment_method
      t.string :customer_name
      t.string :customer_phone
      t.string :customer_email
      t.text :notes
      t.datetime :cancelled_at

      t.timestamps
    end
  end
end
