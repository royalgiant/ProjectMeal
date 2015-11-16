class OrgProductsController < ApplicationController
	before_action :signed_in_user, :user_has_role_in_company?, only: [:index, :new, :create, :edit, :update, :delete, :orders, :completed_orders]
	before_action :registered_company, only: [:index, :new, :create, :edit, :update, :delete]

	def index
	end

	def show
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
	end

	def edit
	end

	def update
	end

	def destroy
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
