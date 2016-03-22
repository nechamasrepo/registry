class ItemsController < ApplicationController

  # Display a Registry
  def index
    # Define which user's registry to display based on the URL
    @user = User.find_by(link_id: params[:link_id])
    unless @user
      flash[:notice] = 'No Registry Found'
      redirect_to root_path and return
    end
      
    # Create empty fulfillments and items so new ones can be created
    @fulfillment = Fulfillment.new
    @item = Item.new        
    # Sort items registry based on params provided by sort dropdown 
    sort_by = params[:sort_by]
    if @user.items.any?
      if sort_by == "price_high"
        @items = @user.items.by_fulfilled.by_price_high
      elsif sort_by == "price_low"
        @items = @user.items.by_fulfilled.by_price_low
      elsif sort_by == "vendor"
        fulfilled_items=@user.items.fulfilled.sort { |a,b| a.store_name.downcase <=> b.store_name.downcase }
        unfulfilled_items=@user.items.unfulfilled.sort { |a,b| a.store_name.downcase <=> b.store_name.downcase }
        @items= unfulfilled_items+fulfilled_items
      else 
        @items = @user.items.by_fulfilled
      end 
     else
        @items = []
     end
      
end
#     authorize @items

  def new
    #     @item = Item.new - This is defined in the index method
    #     authorize @item
  end
  
  
  # Save a new item
  def create
    # Create a new item using the params provided
    @item = Item.new(item_params)
#     authorize @item
    # Set the new item's user to the current user
    @item.user = current_user    
    # Attempt to save the item; if the item saves succesfully... 
    if @item.save
      # Notify the user
      flash[:notice] = "\"#{@item.name}\" was added to your registry."
    # If the item didn't save...
    else
      # Notify the user
      flash[:error] = "There was a problem adding the item to your registry. Please try again."
    end
    # Either way, redirect the user to their own registry (refresh the registry page)
    redirect_to user_registry_path(current_user.link_id)
  end
    
  # Render the item's information so the user can edit
  def edit
    # Select an item bsaed on the item_id provided
    @item = Item.find(params[:id])
    # authorize @item
  end
  
  # Save the updated item information
  def update
    # Find the item to update, based on the item_id provided
    @item = Item.find(params[:id])
    # authorize @item
    # Save the updated item attirubtes
    @item.update_attributes(item_params)
    # Redirect the user to their registry
    redirect_to user_registry_path(current_user.link_id)
  end 
  
  # Delete selected item from a user's registry
  def destroy
    # Find the item to update, based on the item_id provided
    @item = Item.find(params[:id])
#     authorize @item
    # Attempt to delete the item; if the item is deleted...
    if @item.destroy
      # Notify the user...
      flash[:notice] = "\"#{@item.name}\" was deleted successfully from your registry."
     # If the item was not deleted...
     else
      # Notify the user...
      flash[:error] = "There was an error deleting the item from your registry."
     end
     # Either way, redirect the user to their own registry (refresh the registry page)
     redirect_to user_registry_path(current_user.link_id)
  end

  # Render data to for a user to mark an item as fulfilled (create a new fulfillment) on their own registry
  def got_it
    # Create an new, empty fulfillment
    @fulfillment = Fulfillment.new
    # Select the item to mark fulfilled
    @item = Item.find(params[:id])
    # Select all unseen fulfillments for the item to display to the user 
    # (so the user doesn't create a duplicate fulfillment)
    @unseen_fulfillments = @item.fulfillments.where(status: 0)
  end
  
private 
  
  # Define params for adding and updating items
  def item_params
    params.require(:item).permit(:name, :link, :price, :needed, :image_url, :notes, :color, :size)
   end

end