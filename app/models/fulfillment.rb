class Fulfillment < ActiveRecord::Base
  belongs_to :item
  validates :quantity, :numericality => { :greater_than_or_equal_to => 0 }
end
