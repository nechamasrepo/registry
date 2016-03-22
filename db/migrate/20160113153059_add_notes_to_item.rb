class AddNotesToItem < ActiveRecord::Migration
  def change
    add_column :items, :notes, :text
    add_column :items, :color, :string
    add_column :items, :size, :string
  end
end
