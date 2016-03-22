class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  has_many :items
  
  before_create :generate_link
     
  def unseen_fulfillments
    items = self.items
    fulfillments = []
    # Loop through all of the user's items
    items.each do |i|
      # Loop through each of the items' fulfillments
      i.fulfillments.each do |f|    
       # If any of the fulfillments are unseen, add to array
        if f.status == 0
          fulfillments.push(f)
        end
      end 
    end 
  fulfillments
  end 

   protected

   def generate_link
     #*** Generates a unique 5 character id for the user's registry ***
     # Set the user's link_id to a random_id 
     # Loop until the random_id is unique
          self.link_id = loop do
             random_id = SecureRandom.urlsafe_base64(5, false)
             break random_id unless self.class.exists?(link_id: random_id)
          end
   end
  
end