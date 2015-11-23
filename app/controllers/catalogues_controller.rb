class CataloguesController < ApplicationController
  def index
  	# If search is not empty
    
  	if(current_org_person && @contact = OrgContact.find_by(org_person_id: current_org_person.id))
  		@country = TypCountry.find_by_id(@contact['typ_country_id'])
  		@currency = Money.new(1, @country.currency_code).currency
  		session[:currency] = @currency
  		@latitude = @contact["latitude"]
  		@longitude = @contact["longitude"]
  	else
      # If the user had visited before and have geolocation saved in their cookies, use that
      if !cookies[:geolocation].nil?
        @location = JSON.parse(cookies[:geolocation]).symbolize_keys
      else
        # Geolocate the user by IP Address and use the default currency
    		@ip = request.remote_ip
        if Rails.env.production?
          locale = request.location
          @location = {longitude: locale.longitude, latitude: locale.latitude, country_code: locale.country_code}
        else
          @location = GeoIp.geolocation("24.84.225.124")
        end
      end

  		@longitude = @location[:longitude]
  		@latitude = @location[:latitude]
  		@country_code = @location[:country_code]
  		@country = TypCountry.find_by_iso(@country_code)
  		@currency = Money.new(1, @country.currency_code).currency
  		session[:currency] = @currency
      cookies[:geolocation] = {value: JSON.generate(@location), expires: Time.now + 3600 * 24 * 7} # Set cookie for a week
      # If you get an undefined data error, chances are, the internet is too slow
      # Change the timeout in geocoder.rb to more than 240 secs    
  	end
  	if params[:search]
	  	@query = OrgProduct.search(params[:search], 
        where: {
          location: {near: [@latitude, @longitude], within: "100km"},
          expiry_date: {gt: Time.now},
          available_quantity: {gt: 0}
          }, 
        page: params[:page], per_page:20)
	  	@org_products = @query.results # Assign results to @org_products
      if current_org_person
        # Let's check if the user did anything offline and filled up their session cart
        @cart = session[:cart]
        if !@cart.nil? # If there was something in the session
          @cart.each do |c| # Create each item in the session cart in the DB and attach to current user.
            Cart.create(org_person_id: current_org_person.id,
                      org_product_id: c[1]["id"], 
                      name: c[1]["title"], 
                      tax_amount: c[1]["tax_amount"],
                      price: c[1]["price"].to_f, 
                      grocer: c[1]["grocer"],
                      quantity: c[1]["quantity"],
                      weight_in_grams: c[1]["weight"],
                      expiry_date: c[1]["expiry"])
          end 
        end
        @cart = Cart.where(org_person_id: current_org_person.id) #Now retrieve all their items
        @cart = @cart.to_a
        session[:cart] = nil # Clean out the session cart
      else # No registered user, start with a session.
        @cart ||= session[:cart] 
        if @cart.nil? # This makes sure that @cart is a hash no matter what
          @cart = Hash.new # The template needs a hash or it'll throw an error.
        end
      end
	  	
      if @org_products.empty?
	  		flash.now[:danger] = 'There were no results from your search. Please try again'
	  	end
  	else
  		@org_products = {} # Search was empty. Give nothing
  	end
  end
end
