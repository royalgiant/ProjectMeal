class OrgProductsController < ApplicationController

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

end
