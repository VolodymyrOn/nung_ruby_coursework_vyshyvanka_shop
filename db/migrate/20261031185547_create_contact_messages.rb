class CreateContactMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_messages do |t|
      t.string :name
      t.string :email
      t.string :subject
      t.text :body
      t.string :status, default: "new", null: false

      t.timestamps
    end
    add_index :categories, :name, unique: true
  end
end
