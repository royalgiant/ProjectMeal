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

	def stripe
		billing = {
			name: params["stripeBillingName"],
			address: {
				line1: params["stripeBillingAddressLine1"],
				postal_code: params["stripeBillingAddressZip"],
				city: params["stripeBillingAddressCity"],
				region: params["stripeBillingAddressState"],
				country: params["stripeBillingAddressCountryCode"],
			}	
		}

		shipping = {
			name: params["stripeShippingName"],
			address: {
				line1: params["stripeShippingAddressLine1"],
				postal_code: params["stripeShippingAddressZip"],
				city: params["stripeShippingAddressCity"],
				state: params["stripeShippingAddressState"],
				country: params["stripeShippingAddressCountryCode"],
			}
		}

		Stripe.api_key = ENV['STRIPE_SECRET_KEY']

		@customer = Stripe::Customer.create(
			:email => params[:stripeEmail],
			:source => params[:stripeToken]
		)
		stripeTransactions = Array.new # Array used so later we can update the StripeTransactions with their TrxOrder id
		amount_total = 0 # Keep track of the total
		session[:svc].each do |key, array|
			token = Stripe::Token.create({:customer => @customer.id}, {:stripe_account => array['stripe_id']})

			# Charge the customer instead of the card
			charge = Stripe::Charge.create(
				{  	:source 	=> token.id,
					:amount 	=> (array['total']*100).to_i,
					:description => 'Cart Purchase',
					:currency	=> session[:currency]['iso_code'],
					:shipping 	=> shipping,
					:application_fee => (array['fee']*100).to_i
				}, {:stripe_account => array['stripe_id']}
			)

			# If the charge succeeded, then record the data
			if charge[:paid]
				stripeCharge = {
					txn_type: charge[:object],
					currency: charge[:currency],
					total_amount: charge[:amount],
					tax_amount: array['tax']*100.to_i,
					notification_params: charge,
					txn_id: charge[:id],
					status: charge[:paid],
					description: charge[:description] 
				}
				amount_total = amount_total + (array['total']*100).to_i # Keep track of the total
				@sT = StripeTransaction.create(stripeCharge) # make a record in the StripeTransactions table
				stripeTransactions << @sT.id # push the id into the stripeTransactions array for later use
			end
		end


		if !stripeTransactions.empty? # If our stripeTransactions array is not empty, we made some transactions
			@orderInfo = { # Gather the following information
				org_company_id: current_org_person.org_company_id.nil? ? nil : current_org_person.org_company_id,
				bill_to_contact_id: current_org_person.id,
				purchased_at: Time.now,
				total_amount: amount_total,
				transport_method: session[:delivery_method]
			}
			@order = TrxOrder.create(@orderInfo)
			StripeTransaction.where(id:stripeTransactions).update_all(trx_order_id: @order.id) #Update all the records of stripeTransactions with trx_order_id: @order.id
			trx_order_fee = {
				fee_amount: total_projectmeal_fee, #get the fees of all stripe_transcactions for this order
				trx_order_id: @order.id
			}
			@trx_order_fee = TrxOrderFee.create(trx_order_fee)
			@shipAddress = {
				first_name:params["stripeShippingName"],
				last_name:params["stripeShippingName"],
				address1: params["stripeShippingAddressLine1"],
				city: params["stripeShippingAddressCity"],
				region: params["stripeShippingAddressState"],
				postal_code: params["stripeShippingAddressZip"],
				country: params["stripeShippingAddressCountryCode"],
				email: params["stripeEmail"],
				trx_order_id: @order.id
			}
			@shipInfo = ShippingAddress.create!(@shipAddress)
			@order.update(ship_to_contact_id: @shipInfo.id, trx_order_fee_id: @trx_order_fee.id) #Update the order with the new shipping address id
		end

		if !@shipInfo.nil?
			product_sold(@order, @shipInfo)
			session.delete(:svc) # Clean up sessions
			redirect_to action: "stripe_success", id: @order.id
		else
			render :index
		end
		rescue Stripe::CardError => expiry_date
			flash[:error] = e.message
			redirect_to trx_order_path
	end

	# Grabs all the necessary data and presents an invoice display page after purchases
	def stripe_success
		@order = TrxOrder.find(params[:id])
		@pm_fee = TrxOrderFee.find_by_id(@order.trx_order_fee_id)
		# Only the purchaser can see this information
		if current_org_person.id == @order.bill_to_contact_id || current_org_person.org_company_id == @order.org_company_id
			@company = !@order.org_company_id.nil? ? OrgCompany.find(@order.org_company_id) : nil
			@shipAddress = ShippingAddress.find_by(trx_order_id: params[:id])
			@purchase_items = @order.TrxOrderItem.all
			@notification_params_name = JSON.parse(@order.StripeTransaction.all[0][:notification_params])["source"]["name"]
			@total_tax = @order.TrxOrderItem.sum(:tax_amount).to_f
			@currency = Money.new(1, session[:currency]['iso_code']).currency # Gives us the currency symbol to display in the view
			@contact = current_org_person
			invoice_details_hash = { order: @order,
				company: @company,
				shipAddress: @shipAddress,
				purchase_items: @purchase_items,
				notification_params: @notification_params_name,
				total_tax: @total_tax,
				currency: @currency, 
				billed_contact: @contact,
				pm_fee: @pm_fee
			}

			Cart.destroy_all(org_person_id: current_org_person.id)
			InvoiceMailer.invoice_details(invoice_details_hash).deliver_now
			respond_to do |format|
				format.html
				format.pdf do 
					render pdf: "Invoice ##{@order.id}",
						template: "trx_orders/purchase_order.pdf.erb"
				end
			end
		else
			redirect_to root_path, flash: {warning: "You are not authorized to view this page."}
		end
	end

	# For sidebar use, to list all the personal purchases made by user
	def list_personal_purchases
		@purchases = TrxOrder.where(bill_to_contact_id:current_org_person.id).to_a
		@currency = Money.new(1, session[:currency]['iso_code']).currency # Gives us the currency symbol to display in the view
	end

	# For sidebar use, to list all the company purchases made by user
	def list_purchases
		@purchases = TrxOrder.where(org_company_id:current_org_person.org_company_id).to_a
		@currency = Money.new(1, session[:currency]['iso_code']).currency # Gives us the currency symbol to display in the view
	end

	def purchase_order
		@order = TrxOrder.find_by(id:params[:id])
		@pm_fee = TrxOrderFee.find_by_id(@order.trx_order_fee_id)
		# Only the purchaser can see this information
		if current_org_person.id == @order.bill_to_contact_id || current_org_person.org_company_id == @order.org_company_id
			@company = !@order.org_company_id.nil? ? OrgCompany.find_by(id: @order[:org_company_id]) : nil
			@shipAddress = ShippingAddress.find_by(trx_order_id: params[:id])
			@purchase_items = TrxOrderItem.where(trx_order_id: @order[:id])
			@notification_params_name = JSON.parse(@order.StripeTransaction.all[0][:notification_params])["source"]["name"]
			@total_tax = @order.TrxOrderItem.sum(:tax_amount).to_f
			@currency = Money.new(1, session[:currency]['iso_code']).currency # Gives us the currency symbol to display in the view
			@contact = current_org_person
			respond_to do |format|
				format.html
				format.pdf do
					render pdf: "Invoice ##{@order.id}",
						template: "trx_orders/purchase_order.pdf.erb"
				end
			end
		else
			redirect_to root_path, flash: {warning: "You are not authorized to view this page."}
		end
	end

	private
	# Reduce the quantity for the specific items bought in the db and insert the bought items 
	# into trx_order_items table with trx_order_id
	def product_sold(order, sa)
		@cart_item = Cart.where(org_person_id: current_org_person.id)  # Grab whatever is in the cart
		array = Array.new  # Make a new array for holding ids
		@cart_items.each do |id| # Throw all id's into the array
			array << id[:org_product_id].to_i
		end

		@products = OrgProduct.where(id:array) # Find all the products with the id array
		# For each product
		@products.each_with_index do |product, index|

			q = @cart_items.find{ |item| item.org_product_id == product.id}
			#Update the quantity available in OrgProduct after the sale and save.
			product.available_quantity = product.available_quantity.to_i - q.quantity
			product.save
			# Create the hash for insert into trx_order_items
			order_item = {
				name: product.name,
				description: product.description,
				weight_in_grams: product.weight_in_grams,
				price: product.price,
				available_quantity: product.available_quantity,
				quantity: q.quantity,
				expiry_date: product.expiry_date,
				image: product.image,
				delivery_status: 0,
				org_product_id: product.id,
				typ_category_id: product.typ_category_id,
				typ_subcategory_id: product.typ_subcategory_id,
				trx_order_id: order.id, 
				org_company_id: product.org_company_id,
				shipping_address_id: sa.id,
				net_amount: (product.price * q.quantity), # We add fees and taxes on top of the price, so the net amount is always (price + tax + fees - tax - fees)
				tax_amount: (product.price *  q.quantity)*(product.tax_amount/100) # Taxes paid
			}
			item = TrxOrderItem.find_or_initialize_by(trx_order_id: order.id, shipping_address_id: sa.id, org_product_id: product.id) #Create the item
			item.update(order_item)
		end
	end

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
