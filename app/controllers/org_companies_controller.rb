class OrgCompaniesController < ApplicationController
	before_action :signed_in_user, only: [:new]

	def new
		signed_in_user #Be sure the user is signed in before he can create a company
		@company = OrgCompany.new # Make new company object 
		@contactInfo = OrgContact.new.attributes  # Make new contact object w/ empty attributes
		@company.org_contacts.build(@contactInfo)
	end

	def create
		# Find out if the company they guy is creating exists
		if !OrgCompany.exists?(name: company_register_params["name"], typ_company_id: company_register_params["typ_companies"]["id"])
			@company = OrgCompany.create(name: company_register_params["name"], typ_company_id: company_register_params["typ_companies"]["id"], typ_fee_id: company_register_params["typ_fee_id"], description: company_register_params["description"])
			# Sanitize the parameters
			@org_ca = company_params_sanitizer(company_register_params["org_contacts_attributes"]["0"])
			@contact = OrgContact.create(org_company_id: @company.id) #Create a contact in the db
			# If the company is created and we saved the contact information for the company
			if @company && @contact.update_attributes(@org_ca)
				#Flash success message on the next screen
				flash[:success] = "Thank you for registering your company. The ability to edit company information can be done through the email account used to register the company"
				redirect_to edit_org_company_path(@company) # Redirect us to company edit path
			else
				@contactInfo = @org_ca
				@company.org_contact.build(@contactInfo) #Rebuild the new page with the information the user entered
				render :new #Rerender the new page
			end
		else
			flash[:danger] = "The company you are trying to register already exists!"
			@contactInfo = @org_ca 
			@company.org_contacts.build(@contactInfo) #Rebuild the new page with the information the user entered
			render :new #Rerender the new page
		end	
	end

	private

		# Checks if the user is signed in, if they are skip this function, if not
		# redirect him to sign in page and save the last page they were on so
		# we can redirect him back to that page when he signs in.
		def signed_in_user
			unless signed_in?
				store_location
				redirect_to signin_url, flash: {warning: "Please sign in."}
			end
		end

		# strong parameters. These are the parameters we allow.
		def company_register_params
		end

		# Used to sanitize the user inputs. Accepts a hash as the parameter
	    # Returns a hash that is acceptable for updating the database
		def company_params_sanitizer(hash)
			hash[:typ_country_id] = hash.delete :typ_countries
			hash[:typ_country_id] = hash[:typ_country_id][:id]
			hash[:typ_region_id] = hash.delete :typ_regions
		    hash[:typ_region_id] = hash[:typ_region_id][:id]
		    return hash
		end

		 # To see orders, products, company, the person should have a role in the company
	    def user_has_role_in_company?
	    end

	    # Only COO, Director, and Regional Manager are allowed to edit company info
	    def allowed_to_edit_company_info?
	    end

end
