class AddLinkIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :link_id, :string
  end
end
