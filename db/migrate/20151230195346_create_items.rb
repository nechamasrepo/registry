class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.string :link
      t.integer :user_id
      t.decimal :price
      t.integer :needed
      t.integer :fulfilled, :default => 0
      t.integer :pending, :default => 0 #extraneous
      t.timestamps null: false
    end
  end
  def up
    change_column_default :items, :price, :decimal, :scale => 2
  end
end
