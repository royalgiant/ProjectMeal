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
					Cart.create(org_person_id: current_org_person.id
								org_product_id: c[1]["id"],
								name: c[1]["title"],
								tax_amount: c[1]["tax_amount"],
								price: c[1]["price"].to_f, 
			                    grocer: c[1]["grocer"],
			                    quantity: c[1]["quantity"],
			                    weight_in_grams: c[1]["weight"],
			                    expiry_date: c[1]["expiry"])
					)
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
