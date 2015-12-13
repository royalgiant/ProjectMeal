class TrxOrdersController < ApplicationController
	protect_from_forgery except: [:hook]
	before_action :signed_in_user, only: [:index, :new, :create, :edit, :update, :delete, :stripe, :stripe_success, :list_purchases, :purchase_order]
	before_action :user_has_role_in_company?, only: [:list_purchases]

	def index
		@cart = Cart.where(org_person_id: current_org_person.id) #Grab whatever is in the cart
		if @cart.empty? # If there is nothing attached to this user
			@cart = session[:cart] # See if there's anything in the session.
			session[:cart] = nil # Empty out the session
			if !@cart.nil? # If the cart is not empty
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
		end
		@fee = total_projectmeal_fee
		@cart = Cart.where(org_person_id: current_org_person.id) # Just in case we removed anything during our sanitization period with stripe_vendor_charges
		@subtotal = get_subtotal(@cart) # Calculate the total for it
		@total_tax = get_total_tax(@cart)
		@currency = Money.new(1, session[:currency]["iso_code"]).currency # Gives us the currency symbol to display in the view
	end


	private

	# Get subtotal, grabs the total of the cart and sanitizes the session variables
	def get_subtotal(cart_array)
		@cart = price_session_sanitization(cart_array)
		@total = 0
		if @cart.blank? # do nothing
		else # Add the price of each item * its quantity to the running total
			@cart.each do |price| 
	            @total = @total + (price["price"].to_f * price["quantity"].to_f)
	        end
	    end
	    return @total # return the subtotal
	end

	def get_total_tax(cart_array)
		@cart = price_session_sanitization(cart_array)
		@total_tax = 0
		if @cart.blank? #do nothing...	
		else # Add the price of each time * it's quantity to the running total
			@cart.each do |price| 
				if !price["tax_amount"].nil?
					@total_tax = @total_tax + (price["price"].to_f * price["quantity"].to_f)*(price["tax_amount"]/100)
				end
			end
		end
		return @total_tax # return the total_tax
	end

	def price_session_sanitization(cart_array)
		# Check if we have a cart_array passed in, if we do, use that, if not, then do a DB call
		if cart_array.empty?
			@cart = Cart.where(org_person_id: current_org_person.id) # Grab whatever is in the cart
		else
			@cart = cart_array
		end
		array = Array.new # Make a new array for sanitization
		# Go through the cart and collect the ids of each item, so we can get the price from the DB
		# to ensure that session variables like price were not manipualted
		@cart.each do |id|
			array << id[0].to_i
		end
		@products = OrgProduct.where(id:array) # Select the products from the ids
		# Each product, grab the price from the db and assign to @cart variable
		@products.each do |product|
			@cart[product.id.to_s]["price"] = product["price"].to_s
		end
		return @cart
	end

	# Calcuales total projectmeal fee for all items in a transaction
	def total_projectmeal_fee
		session[:svc] = stripe_vendor_charges # Might as well set the session
		fee = 0
		session[:svc].each do |key, array|
			fee = fee + array[:fee]
		end
		return fee
	end

	# This function breaks down our cart and tallies up the total according to vendor
	# It returns an array [stripe_user_id, total]
	def stripe_vendor_charges
		@cart_items = Cart.where(org_person_id: current_org_person.id)  # Grab whatever is in the cart
		array = Array.new  # Make a new array for holding ids
		@cart_items.each do |id| # Throw all id's into the array
			array << id[:org_product_id].to_i
		end
		@products = OrgProduct.where(id:array) # Find all the products with the id array

		h = Hash.new  # Make a new hash for holding ids
		@products.each do |product|
			# We need to find the COO, to get his stripe_user_id
			person = OrgPerson.where(org_company_id: product.org_company_id, typ_position_id: 1).where.not(stripe_user_id: nil)
			c = @cart_items.find{ |item| item.org_product_id == product.id } # This is to match the product to the cart item to get "c"
			
			if !person.empty?
				c = @cart_items.find{ |item| item.org_product_id == product.id } # This is to match the product to the cart item to get "c"
				subtotal = c.price * c.quantity # calculate subtotal
				fee = projectmeal_fee(subtotal, product) #calculate the projectmeal fee
				tax = c.tax_amount.nil? ? 0 : subtotal * (c.tax_amount/100) # calculate any taxes
				if !h[person[0][:stripe_user_id]].blank? # If the stripe_user_id already existed (i.e. selling 2 different items by same vendor)
					h[person[0][:stripe_user_id]] = {total: (h[person[0][:stripe_user_id]][:total] + (subtotal+fee+tax)).round(2).to_f,
													fee: (h[person[0][:stripe_user_id]][:fee] + fee).round(2).to_f,
													tax: (h[person[0][:stripe_user_id]][:tax] + tax).round(2).to_f,
													stripe_id: person[0][:stripe_user_id]
										}
				else # first item being sold by vendor, add the vendor to the list
					h[person[0][:stripe_user_id]] = { total: 0 + (subtotal+fee+tax).round(2).to_f, 
													  fee: fee.round(2).to_f,
													  tax: tax.round(2).to_f,
													  stripe_id: person[0][:stripe_user_id]
										}
				end
			else
				Cart.destroy(c.id)
				flash[:warning] = "One or more of the items checked out have been removed because orders are not being taken for those items at the moment."
			end
		end
		return h
	end

	# Calculates projectmeal fee for one kind of item in a transaction
	def projectmeal_fee(subtotal, product)
		if !product.org_company.typ_fee_id.nil?
			fee = TypFee.find_by_id(product.org_company.typ_fee_id) # Look up what fee is charged with this vendor 
			projectmeal_fee = subtotal * fee.fee_percentage # calculate what fee we charge
		else
			projectmeal_fee = subtotal * 0.05
		end
		return projectmeal_fee.round(2).to_f # return the fee
	end

	def signed_in_user
    	unless signed_in?
        	store_location
        	redirect_to signin_url, flash: {warning: "Please sign in before you checkout."}
    	end
    end

    # To see orders, products, company, the person should have a role in the company
    def user_has_role_in_company?
    	if current_org_person.typ_position_id.blank?
        	redirect_to edit_org_person_path(current_org_person.id), flash: {warning: "You need to be approved by the company you have been assigned to first to access the requested page."}
    	end 
    end

end
