class ChangeStatusInFulfillments < ActiveRecord::Migration
  def change
    change_column :fulfillments, :status, :integer, :default => 0
  end
end
