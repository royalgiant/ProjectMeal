class OrgProductsController < ApplicationController
	before_action :signed_in_user, :user_has_role_in_company?, only: [:index, :new, :create, :edit, :update, :delete, :orders, :completed_orders]
	before_action :registered_company, only: [:index, :new, :create, :edit, :update, :delete]

	def index
		@contact = OrgContact.find_by(org_person_id: current_org_person.id)
		@country = TypCountry.find_by_id(@contact['typ_country_id'])
		@currency = Money.new(1, @country["currency_code"]).currency
		if current_org_person.org_company_id
			@org_products = OrgProduct.paginate(page: params[:page]).where(org_company_id: current_org_person.org_company_id)
		end
	end

	def show
		@productInfo = OrgProduct.find_by_id(params['id'])
		@category = TypCategory.find_by_id(@productInfo.typ_category_id).name
		@subcategory = TypSubcategory.find_by_id(@productInfo.typ_subcategory_id).name
		@contactInfo = OrgContact.find_by_org_company_id(@productInfo.org_company.id)
		@currency = Money.new(@contactInfo.typ_country.currency_code).currency
		session[:currency] = @currency
		if current_org_person
			@cart = Cart.where(org_person_id: current_org_person.id, org_product_id: @productInfo.id)
			if @cart.empty?
				@cart ||= session[:cart][@productInfo.id.to_s] # Check whether we saved a session variable for this item
				if !@cart.empty? # There was a session variable for this item, attach it to this users cart
					Cart.create(org_person_id: current_org_person.id,
						org_product_id: @cart["id"],
						name: @cart["title"],
						price: @cart["price"].to_f,
						grocer: @cart["grocer"],
						quantity: @cart["quantity"],
                        weight_in_grams: @cart["weight"],
                        expiry_date: @cart["expiry"])
					session[:cart][@productInfo.id.to_s] = nil # Clean out the session cart
				end
			end
		else
			@cart ||= session[:cart]
			if @cart.nil? # This makes sure that @cart is a hash no matter what
				@cart = Hash.new # The template needs a hash or it'll throw an error.
			end
		end
	end

	def new
		signed_in_user  # Only signed in users can post
		@tax_details = get_tax_details # Get the tax options for this post based on company location
		if current_org_person
			registered_company # Make sure they are associated w/ a company
			@product = OrgProduct.new # make a new product object
		end
	end

	def create
		# Grab the contact information for the company
		@tax_details = get_tax_details # Get the tax options for this post based on company location
		@companyContact = OrgContact.find_by(org_company_id: current_org_person.org_company_id, org_person_id: nil)
		@productInfo = product_params_sanitizer(product_params) # Use sanitizer to return a sanitized hash
		@productInfo[:org_company_id] = @companyContact["org_company_id"] # Add the org_company_id in the hash
		@productInfo[:latitude] = @companyContact["latitude"]
		@productInfo[:longitude] = @companyContact["longitude"]
		@product = OrgProduct.create(@productInfo)

		if @product.update_attributes(@productInfo) # If we save properly
			flash[:success] = "Thank you. Your product - "+@productInfo['name']+" - has been posted"
			redirect_to edit_org_product_path(@product.id)	# Redirect us to product edit path
		else
			render :new
		end
	end

	def edit
		signed_in_user # Only signed in users can edit post
		@tax_details = get_tax_details # Get the tax options for this post based on company location
		if current_org_person
			registered_company # Make sure they are associated w/ a company
			@product = OrgProduct.find(params[:id])
		end
	end

	def update
		# Grab the contact information for the company
		@companyContact = OrgContact.find_by(org_company_id: current_org_person.org_company_id, org_person_id: nil)
		@productInfo = product_params_sanitizer(product_params) # Use sanitizer to return a sanitized hash
		@productInfo[:org_company_id] = @companyContact["org_company_id"] # Add the org_company_id in the hash
		@productInfo[:latitude] = @companyContact["latitude"]
		@productInfo[:longitude] = @companyContact["longitude"]
		@product = OrgProduct.find(params[:id])
		# Try updating the product record 
		if @product.update_attributes(@productInfo)
			flash[:success] = @productInfo['name'].capitalize+" - has been updated"
			redirect_to edit_org_product_path(@product.id)	# Redirect us to product edit path
		else
			render :edit
		end
	end

	def destroy
		OrgProduct.find(params[:id]).destroy
		flash[:success] = "Listing deleted."
		redirect_to org_products_path
	end

	# Gets all the pending order requests by customers and must be completed.
	def orders
		@currency = Money.new(1, session[:currency]["iso_code"]).currency
		if current_org_person.org_company_id
			@orders = TrxOrderItem.where(org_company_id: current_org_person.org_company_id, delivery_status: 0)
		end
		@total = get_total(@orders)
	end

	# Gets all the orders that have been delivered and completed
	def completed_orders
		@currency = Money.new(1, session[:currency]["iso_code"]).currency
		if current_org_person.org_company_id
			@orders = TrxOrderItem.where(org_company_id: current_org_person.org_company_id, delivery_status: 1)
		end
		@total = get_total(@orders)
	end

	def vote_product
		vote = params[:vote]
		@product = OrgProduct.find_by_id(params[:id])
		@user = OrgPerson.find_by_id(current_org_person.id)
		if vote == "upvote"
			# User disliked product, but clicked upvote, so undislike and like the product
			if @user.voted_down_on? @product
				@product.undisliked_by @user
				@product.liked_by @user
			# User liked product, but clicked upvote, so unlike the product
			elsif @user.voted_up_on? @product
				@product.unliked_by @user
			# User likes product for first time
			else
				@product.liked_by @user
			end	
		elsif vote == "downvote"
			# User liked product, but clicked downvote, so unlike and dislike the product
			if @user.voted_up_on? @product
				@product.unliked_by @user
				@product.disliked_by @user
			# User disliked product, but clicked downvote, so undislike the product
			elsif @user.voted_down_on? @product
				@product.undisliked_by @user
			# User dislikes product for first time
			else
				@product.disliked_by @user
			end
		end
		true
	end

	def delivery_status
		TrxOrderItem.update(params[:trx_item_order_id], delivery_status: params[:delivery_status])
		render nothing:true
	end

	def send_product_ready_email
		@item = TrxOrderItem.find_by_id(params[:trx_item_order_id])
		@order = TrxOrder.find_by_id(@item[:trx_order_id])
		@pm_fee = TrxOrderFee.find_by_id(@order.trx_order_fee_id)
		@company = !@order.org_company_id.nil? ? OrgCompany.find(@order.org_company_id) : nil
		@shipAddress = ShippingAddress.find_by(trx_order_id: @order[:id])
		@purchase_items = @order.TrxOrderItem.all
		@total_tax = @order.TrxOrderItem.sum(:tax_amount).to_f
		@currency = Money.new(1, session[:currency]['iso_code']).currency # Gives us the currency symbol to display in the view
		@contact = OrgPerson.find_by_id(@order[:bill_to_contact_id])
		invoice_details_hash = {order: @order, 
			company: @company, 
			shipAddress: @shipAddress, 
			purchase_items: @purchase_items,
			currency: @currency, 
			billed_contact: @contact,
			total_tax: @total_tax,
			pm_fee: @pm_fee
		}
		ProductReadyMailer.send_product_ready_email(invoice_details_hash, @item).deliver_now
	end

	private

	def get_tax_details
		# Find company's contact information
		company = OrgContact.find_by(org_company_id: current_org_person.org_company_id, org_person_id: nil)
		# Find the region where this company lies, and its respective sales taxes
		type_sales_taxes = company.typ_region.typ_sales_taxes
		@tax_details = Hash.new
		total_tax = 0
		type_sales_taxes.each do |tax|
			total_tax = total_tax + tax.tax_rate # Total up the total taxes
			# Put into the hash a key-value pair of tax_name => tax_rate
			@tax_details[tax.typ_tax.name] = tax.tax_rate
		end
		@tax_details["Total"] = total_tax
		@tax_details["None"] = 0
		return @tax_details	
	end

	# Get the total money made of a list of items
	def get_total(array)
		total = 0
		array.each do |product|
			total = total + (product.price * product.quantity)
		end
		return total.to_f
	end

	# strong parameters. These are the parameters we allow.
	def product_params
    	params.require(:org_product).permit(:name, :tax_amount, {typ_category: :id}, {typ_subcategory: :id}, :price,
    	:weight_in_grams, :available_quantity, :expiry_date, :description, :online_order_available, :image)
    end

	def signed_in_user
    	unless signed_in?
        	store_location
        	redirect_to signin_url, flash: {warning: "Please sign in."}
    	end
    end

    # To see orders, products, company, the person should have a role in the company
    def user_has_role_in_company?
    	if current_org_person.typ_position.blank?
    		store_location
        	redirect_to edit_org_person_path(current_org_person.id), flash: {warning: "You need to be approved by the company you have been assigned to first to access the requested page."}
    	end 
    end

    # This checks if the user is associated with a company.
	# You will only ever need this for a user to post products
	def registered_company
		@companyContact = OrgContact.joins(:org_company).where(email: current_org_person.email, org_person_id: current_org_person.id, org_company_id: current_org_person.org_company_id)
		if @companyContact.empty?
			redirect_to edit_org_person_path(current_org_person.id), flash: {warning: "Please register with a company first"}
		end
	end

	# Used to sanitize the user inputs. Accepts a hash as the parameter
    # Returns a hash that is acceptable for updating the database
    def product_params_sanitizer(hash)
	    hash[:typ_subcategory_id] = hash.delete :typ_subcategory
	    hash[:typ_subcategory_id] = hash[:typ_subcategory_id][:id]
	    hash[:typ_category_id] = hash.delete :typ_category
	    hash[:typ_category_id] = hash[:typ_category_id][:id]
	    return hash
   	end
end
