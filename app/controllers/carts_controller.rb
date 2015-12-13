class CartsController < ApplicationController
	# Shows all the items client has ordered in the shopping cart
	def index
		@org_products = Array.new
		@currency = Money.new(1, session[:currency]["iso_code"]).currency
		# If the session delivery method is nil, default to pickup
		if session[:delivery_method].nil?
			session[:delivery_method] = 'pickup'
		end
		# Search to see if this user already have existing items to checkout in the db
		if current_org_person
			session_to_cart = session[:cart] # Let's check our session to see if the user carted anything while not signed in.
			if !session_to_cart.nil? # If they did
				session_to_cart.each do |c| # Create each item in the session cart in the DB and attach to current user.
					if cart = Cart.find_by(org_person_id: current_org_person.id, org_product_id: c[1]["id"]) # Check if the item exists in DB
						cart.update(org_person_id: current_org_person.id, # If it did, update it
									org_product_id: c[1]["id"],
									name: c[1]["title"], 
									tax_amount: c[1]["tax_amount"],
			                      	price: c[1]["price"].to_f, 
			                      	grocer: c[1]["grocer"],
			                      	quantity: c[1]["quantity"],
			                      	weight_in_grams: c[1]["weight"],
			                      	expiry_date: c[1]["expiry"])
					else # else create it	
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
			session[:cart] = nil
			@products = Cart.where(org_person_id: current_org_person.id)
		else
			@products = session[:cart]
		end

		if @products == nil
		else
			@products.to_a.each do |product|
				if current_org_person
					@productRecord = product.org_product # products are from cart.
				else # we got cart data from a session
					@productRecord = OrgProduct.find_by_id(product[0])
				end
				if @productRecord # The products are from session, check if the item is in the db
					expiry = @productRecord.expiry_date.to_date.to_formatted_s(:long_ordinal) # Get its expiry
					available_quantity = @productRecord.available_quantity # Get its quantity
					if available_quantity.to_i > 0 && Time.now < expiry	# If it's not expired, or quantity > 0
						@org_products << [@productRecord, product] # We can show it
					else 
						@org_products << [@productRecord, product] #This should not be here?
						if current_org_person #It was cart DB data
							Cart.destroy(product.id) # Delete the item from the Cart DB attached to the user
						else
							session[:cart].delete(p["id"]) # Delete the item from the session
						end
					end
				end 
			end
		end
	end

	def add
		# cart_item – try to find the item in the db if it exists
		if current_org_person
			cart_item = Cart.find_by(org_person_id: current_org_person.id, org_product_id: params[:product_id])
		end
		# It doesn't exist, and the user is logged on, create it for this user in the db.
		if cart_item.blank? && current_org_person
			cart_item = Cart.create(org_person_id: current_org_person.id,
									org_product_id: params[:product_id], 
									name: params[:title],
									tax_amount: params[:tax],
									price: params[:price], 
									grocer: params[:grocer],
									quantity: params[:quantity],
									weight_in_grams: params[:weight],
									expiry_date: params[:expiry])
		# It exists, and user is logged on, update it in the db.
		elsif cart_item && current_org_person
			cart_item.update(name: params[:title], 
							tax_amount: params[:tax],
							price: params[:price], 
							grocer: params[:grocer],
							quantity: params[:quantity],
							weight_in_grams: params[:weight],
							expiry_date: params[:expiry])
		# The user is not logged on, so we use sessions
		else
			session[:cart] ||={}
			session[:cart][params[:product_id]] = {id: params[:product_id],
												title: params[:title],
												tax_amount: params[:tax],
												price: params[:price], 
												grocer: params[:grocer],
												quantity: params[:quantity],
												weight: params[:weight],
												expiry: params[:expiry]

			}
		end
		render nothing:true
	end

	def add_delivery_method
		session[:delivery_method] = nil
		session[:delivery_method] = params[:deliveryMode]
		render nothing:true 
	end

	def destroy
		# Delete the item from the cart
		if current_org_person
			Cart.destroy(params[:id])
		else
			session[:cart].delete(params[:id])
		end
		redirect_to carts_path # Redirect to the shopping cart
	end
end
