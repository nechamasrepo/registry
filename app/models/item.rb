class Item < ActiveRecord::Base
  belongs_to :user
  has_many :fulfillments
  validates :name, presence: true
  validates :link, presence: true
  validates :price, presence: true
  validates :needed, presence: true
  validates :user_id, presence: true
  default_scope { order('created_at DESC') }
  scope :by_fulfilled, -> { order("needed>fulfilled DESC") }
  scope :by_price_high, -> { order("price DESC") }
  scope :by_price_low, -> { order("price ASC") }
  scope :unfulfilled, -> { where("needed>fulfilled") }
  scope :fulfilled, -> { where("needed<=fulfilled") }
  
  require 'open-uri'

  def store_name

    short_link = self.link
    # *** Remove Intro To HOST ***
    # find index of intros (www. and/or //)  
    dot_index = short_link.index("www.")
    slash_index = short_link.index("//")
    # split the short_link into 3 parts and grab the last part (after the intro)
    if dot_index != nil
      short_link = short_link.partition("www.")[2]
    elsif slash_index != nil
      short_link = short_link.partition("//")[2]
    end

    # *** Remove HOST extension (and everything afterwards) ***    
    # keep everything till "."
    # (split the short_link into 3 parts and grab the first part (until the period))    
    short_link.partition(".")[0]
  end 
  
  def affiliate_link
    # *** Define affiliate program information. ***
    # Each array in the affiliate_programs array contains the website, affiliate code and affiliate type)
    affiliate_programs = [
      ["feldheim.com", "acc=9778d5d219c5080b9a6a17bef029331c", "param"],
      ["shellsheli.com", "Click=6288", "param"],
      ["weebly.com", "http://www.shareasale.com/r.cfm?b=358504&u=1121120&m=37723&urllink={link}&afftrack=", "link"]
    ]    
    # Create link variable to modify
    #(Will return the original link if we don't have an affiliate program with the website)
    affiliate_link = self.link

    # Check if we have an affiliate program with the website
    affiliate_programs.each do |p|
      # If we do have an affiliate program with the website...
      if self.link.include?(p[0])        
        # *** Check what type of program it is and return the correctly modified link *** 
        # If type is param...
        if p[2] == "param"
          # If url contains ? (there are already params in the url) append & instead of ?
          if self.link.include?("?")
            character = "&"
          else 
            character = "?"
          end 
          affiliate_link = self.link + character + p[1]
        
        # If type is link...
        elsif p[2] == "link"
          affiliate_link = p[1].sub! '{link}', self.link
        end 
        
        # Stop loop 
        break
      end 
    end 
    affiliate_link
  end 

end