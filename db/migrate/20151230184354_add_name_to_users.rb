class AddNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :wedding_date, :date
    add_column :users, :other_first_name, :string
    add_column :users, :other_last_name, :string
  end
end