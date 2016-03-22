class FulfillmentsController < ApplicationController
  
  # Display unseen fulfillments to the user
  def index
    # If the user has no unseen fulfillments...
    if current_user.unseen_fulfillments.empty?
      # Reditect to their registry
      redirect_to user_registry_path(current_user.link_id)
    # I the user has unseen fulfillments...   
    else
      # Select the user's unseen fulfillments
      @fulfillments = current_user.unseen_fulfillments
    end 
  end
  
  # User can mark a fulfillment as seen
  def mark_seen
    # Define the fulfillment based on the selected fulfillment's id 
    fulfillment = Fulfillment.find(params[:id])
    # If the fulfillment's status is "unseen"(0)...
    if fulfillment.status == 0 
      # Mark the status as "seen"(1)...
      fulfillment.status = 1
      # And save the fulfillment
      fulfillment.save
    # If the fulfillment's status is "unseen"(0)...
    else
      # Notify the user that there was an error
      flash[:error] = "There was an error processing your request."
    end 
    redirect_to :back
  end 

  # User can mark a fulfillment as spam (and return item to 'unpurchased status')
 def mark_spam
    # Define the fulfillment based on the selected fulfillment's id    
   fulfillment = Fulfillment.find(params[:id])
   # If the fulfillment's status is not spam (2)...
   if fulfillment.status != 2 
    # Mark the status as spam (2)...
    fulfillment.status = 2
    # And adjust the item's count of fulfillments 
    item = fulfillment.item
    item.fulfilled -= fulfillment.quantity
    # If the item and the fulfillment saved...
    if item.save && fulfillment.save
      # Notify the user
      flash[:notice] = "The fulfillment by #{fulfillment.buyer_name} was marked as spam."
    # If the item and fulfillment did not save...
    else
      # Notify the user that there was an error
      flash[:error] = "There was an error processing your request."
    end
  # If the fulfillment's status is spam (2)...     
  else
    # Notify the user that there was an error     
    flash[:error] = "There was an error processing your request."
  end
  redirect_to :back
end 

  # Create a new fulfillment (by user)
   def user_create
     # Create new fulfillment with the user provided params
     @fulfillment = Fulfillment.new(params.require(:fulfillment).permit(:buyer_name, :quantity, :item_id))
     # Set the fulfillment status to seen (1)
     @fulfillment.status = 1
     # Adjust the number purchased for the fulfillment's item
     item = Item.find(@fulfillment.item_id)
     item.fulfilled += @fulfillment.quantity
     item.save
     gift = pluralize_gift(@fulfillment, item)
     gift = item.name   
     # If the fulfillment was saved...
    if @fulfillment.save
      # Notify the user
      flash[:notice] = "#{@fulfillment.quantity} #{gift} #{gift_verb(@fulfillment)} removed from your registry."
     # If the fulfillment was not saved...
     else
     # Notify the user that there was an error
      flash[:error] = "There was an error. #{@fulfillment.quantity} #{gift} #{gift_verb} not removed from your registry. Please try again later."
     end
  # Either way, send the user to their registry
  redirect_to user_registry_path(current_user.link_id)
end  
  
# Return the verb to preceed: "removed from your registry"
def gift_verb(fulfillment)
      # If multiple items were fulfilled...
      if fulfillment.quantity > 1
        "were"
      # If one item was fulfilled  
      else
        "was"
      end
end 

def pluralize_gift(fulfillment, item)
      if fulfillment.quantity > 1
        item.name.pluralize
      else
        item.name
      end
  end 

  # Allow anyone to create a fulfillment on someone's registry
  def create
    # Create a fulfillment given the params
    @fulfillment = Fulfillment.new(params.require(:fulfillment).permit(:buyer_name, :buyer_email, :quantity, :message, :item_id))
    # Adjust the number purchased for the fulfillment's item
    item = Item.find(@fulfillment.item_id)
    item.fulfilled += @fulfillment.quantity
    item.save
    # Define variable with the names of the couple that owns the registry
    couple_names = "#{item.user.first_name} & #{item.user.other_first_name}"
#     gift = pluralize_gift(@fulfillment, item)
    gift = item.name
    # If the fulfillment is saved...
    if @fulfillment.save
      # Notify the user
      flash[:notice] = "Thank you! #{couple_names} were informed that you will be buying them #{@fulfillment.quantity} #{gift}"
    # If the fulfillment is not saved...
    else
      # Notify the user of an error
      flash[:error] = "There was a problem removing the item that you purchased from the registry. Please try again later."
    end
  redirect_to :back
  end 

end