class CreateFulfillments < ActiveRecord::Migration
  def change
    create_table :fulfillments do |t|
      t.string :buyer_name
      t.string :buyer_email
      t.integer :item_id
      t.text :message
      t.integer :quantity

      t.timestamps null: false
    end
  end
end
