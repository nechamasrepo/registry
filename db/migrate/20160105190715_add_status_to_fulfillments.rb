class AddStatusToFulfillments < ActiveRecord::Migration
  def change
    add_column :fulfillments, :status, :integer
  end
end
