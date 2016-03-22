class PublicController < ApplicationController
  def landing
  end

  # Search for a user given a first name and a last name
  def search_results
    # Define lowercase variables of the search terms
    first = (params[:user][:first_name]).downcase
    last = (params[:user][:last_name]).downcase
    # Return a user where the search terms match the user's names OR the user's fiance's name
    @results = User.where(["(LOWER(first_name) = :first AND LOWER(last_name) = :last) OR (LOWER(other_first_name) = :first AND LOWER(other_last_name) = :last)", {first: first, last: last}])
    # Return the search terms    
    @query = "'#{params[:user][:first_name]} #{params[:user][:last_name]}'"
  end 

# Collect emails that are submited into the "Create a Registry" modal
  def new_user_registration_collect_email
    # Create a new contact with the email provided
    contact = Contact.new(params.permit(:email))
    # Save the contact
    contact.save
    # Redirect to the "Create a Registry" page
    redirect_to new_user_registration_path(email: params[:email])
  end

  def scrape
    require 'open-uri'
    product_url = params[:url]
  
    # before everything see if someone else listed a product with the same link
    item = Item.where(link: product_url).last
    if item
      render json: {:url => product_url, :title => item.name, :price => item.price.to_f, :images => [item.image_url], :found => true }
      return
    end
    
    # Fetch and parse HTML document
    html = Nokogiri::HTML(open(product_url, {"User-Agent" => "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.97 Safari/537.11"}).read)
  
    # get css
    css = get_css(html, product_url)
    
    # get the content
    content = html.at_css('body').inner_text

    product_price = find_price(content)

    # find html element containing the price  
    elements = html.css(":contains('#{product_price}')")

    len = content.length+1;
    el = nil;

    # loop through the elements and find the one with the least amount of text other then the price in it
    elements.each do |element|
      elLen = element.inner_text.gsub("$#{product_price}", "").length
	    if elLen < len
		    len = elLen
		    el = element
	    end
    end

    images = nil
    title = nil
    # loop through all parents
    while el = el.parent
      # if we don't have images yet
      if images == nil
        # find all the images in its parent
        el_images = el.css('img')
        # if there are images
        if el_images.length > 0
          images_size = []
          # go through them and grab all the ones bigger then 50px by 50px
          el_images.each do |image|
            dimensions = get_image_dimensions(image, css, product_url)
            if dimensions[0].to_i < 50 || dimensions[1].to_i < 50
              html.delete(image)
            else
              images_size.push([image.attr('src'), dimensions[0].to_i * dimensions[1].to_i])
            end
          end
          
          # if ther are any bigger ones then save them as the images
          if images_size.length > 0
            images = images_size
          end
        end
      end
          
	
      # get title
	    titles = el.css('h1, h2, h3, h4, h5, h6')
	    if titles.length > 0 && title == nil
		    title = titles.first.inner_text
	    end

	    # end search if we found an image and a title
      if images && title
		    break
	    end
    end

    # get html page title
    page_title = html.at_css('title').inner_text

    # if the page title does not include the found title use the page title as the title instead
    if !(page_title.include? title)
	    title = page_title
    end

    image_src_list = []
    images.sort! {|x, y| y[1] <=> x[1]}
    images.each do |image|
      # no protocol then add the beginning
      image_src_list.push(URI.join(product_url , image[0] ).to_s)
    end
    
    render json: {:url => product_url, :title => title, :price => product_price[1..-1].to_f, :images => image_src_list }
  end



  # GET ALL CSS FROM HTML PAGE
  protected
  def get_css(html, url)
    parser = CssParser::Parser.new
    link_tags = html.css('link')
    style_tags = html.css('style')
    css = ""
    
    # load all links
    link_tags.each do |link|
      if link.attr('href').include? '.css'
        if valid?(link.attr('href'))
          parser.load_uri!(URI.join(url , link.attr('href')).to_s)
        end
      end
    end
    
    # load all local tags
    style_tags.each do |style|
      css += style.inner_text
    end
    
    parser.load_string!(css)
    
    # return parser
    parser
  end

  protected
  def get_image_dimensions(el, css, url)
    # get image size if its not put in via data
    if el.attr('src').index('data:') == nil
      dimensions = FastImage.size(URI.join(url , el.attr('src')).to_s);
    end
    if dimensions != nil
      #width over height
      width_to_height_ratio = dimensions[0]/dimensions[1]
      #height over width
      height_to_width_ratio = dimensions[1]/dimensions[0]
    else
      dimensions = [0,0]
    end
    
    # get width and get height
    width = get_property(el, 'width', css)
    height = get_property(el, 'height', css)
    
    # if no width or height styling then return the dimensions
    if width == nil && height == nil
      dimensions = dimensions
    # else if there is no width calculate it from height
    elsif width == nil
      dimensions[1] = height
      dimensions[0] = height * width_to_height_ratio
    # else if there is no height calculate it from width
    elsif height == nil
      dimensions[0] = width
      dimensions[1] = width * height_to_width_ratio
    end
    dimensions
  end

  protected
  def get_property(el, prop, css)
    r = nil
    # get the width from inline style
    if el.styles[prop]
      r = el.styles[prop]
    end
    
    #get the width from the id
    if el['id'] && r == nil
      rules = css.find_rule_sets(["#"+el['id']])[0]
      if rules
        if rules[prop]
          r = rules[prop]
        end
      end
    end
    
    #get the width from classes
    if el['class'] && r == nil
      rules = css.find_rule_sets(el.classes)
      rules.each do |set|
        if set[prop]
          r = set[prop]
        end
      end
    end
    
    #get the width from attribute
    if el[prop] && r == nil
      r = el[prop]
    end
    
    #return value
    r
  end

  protected
  def find_price(content)
    # get all prices from the page
    prices = content.scan(/\$\d*\.\d{2}/)

    # find the price
    product_price = "0.00"

    prices.each do |price|
      # remove dollar sign
      price.slice!(0)

      # if price is greater then 0 then that is the product price
      if price.to_f > 0
        product_price = "$" + price
        break
      end
    end
    
    # return price
    product_price
  end

  protected
  def valid?(url)
    uri = URI.parse(url)
    uri.kind_of?(URI::HTTP)
  rescue URI::InvalidURIError
    false
  end

end