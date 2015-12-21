class OrgCompaniesController < ApplicationController
	before_action :signed_in_user, :user_has_role_in_company?, only: [:show, :edit, :update, :list_deliverers, :ajax_add_deliverers, :preferred_deliverers, :people ]
	before_action :allowed_to_edit_company_info?, only: [:edit, :update]

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
				# Flash success message on next screen
		    	flash[:success] = "Thank you for registering your company. The ability to edit company information can be done through the email account used to register the company"
				redirect_to edit_org_company_path(@company)	# Redirect us to company edit path
			else 
				@contactInfo = @org_ca 
				@company.org_contacts.build(@contactInfo) #Rebuild the new page with the information the user entered
				render :new #Rerender the new page
			end
		else
			flash[:danger] = "The company you are trying to register already exists!"
			@contactInfo = @org_ca 
			@company.org_contacts.build(@contactInfo) #Rebuild the new page with the information the user entered
			render :new #Rerender the new page
		end
	end

	def show 
		@company = OrgCompany.find(params[:id]) #Find the company we are dealing with
		@type_company = TypCompany.find_by_id(@company.typ_company_id) # Find the type of the company
		# Attributes used to prepopulate the input fields
		@contactInfo = OrgContact.find_or_create_by(org_company_id: params[:id], org_person_id: nil).attributes
		@country = TypCountry.find_by_id(@contactInfo['typ_country_id']) # Find the type of the company
		@region = TypRegion.find_by_id(@contactInfo['typ_region_id']) # Find the type of the company
	end

	def edit
		@company = OrgCompany.find(params[:id]) #Find the company we're dealing with
		# Attributes used to prepopulate the input fields
		@contactInfo = OrgContact.find_or_create_by(org_company_id: params[:id], org_person_id: nil).attributes
		@company.org_contacts.build(@contactInfo) # Build the contact input fields associated with company
	end

	def update
		@company = OrgCompany.find(params[:id]) #Find the company we are dealing with
		# Sanitize the parameters
		@companyInfo = {description: company_edit_params["description"], avatar: company_edit_params["avatar"]}
		@org_ca = company_params_sanitizer(company_edit_params["org_contacts_attributes"]["0"])
		@contact = OrgContact.find_or_create_by(org_company_id: @company.id, org_person_id: nil) #Find/Create a contact in the db if it doesn't exist
		@contactInfo = @contact.attributes # If the update was not sucessful, we need the previous record data to rerender the edit page
		# Try updating the the contact record  
		if @contact.update_attributes(@org_ca) && @company.update(@companyInfo)
	    	flash[:success] = "Company information updated" #Flash message success on next screen
			redirect_to edit_org_company_path(@company)	# Go back to edit page
		else 
			@company.org_contacts.build(@contactInfo) #Build the fields with the previous record data
			render :edit # Rerender edit page
		end
	end

	# Shows the profile of the company from the catalogues search result item
	def company_profile
		@company = OrgCompany.find_by_id(params[:id])
		@contactInfo = OrgContact.find_by(org_company_id: params[:id], org_person_id: nil)
		@country = TypCountry.find_by_id(@contactInfo['typ_country_id']) # Find the type of the company
		@region = TypRegion.find_by_id(@contactInfo['typ_region_id']) # Find the type of the company
	end

	def people
		@people = OrgContact.where(org_company_id: current_org_person.org_company_id).where.not(org_person_id: nil)
		@cu_position = current_org_person.typ_position_id
	end

	def list_deliverers
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
			        @location = GeoIp.geolocation(@ip)
			    else
			        @location = GeoIp.geolocation("24.84.225.123")
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

  		@query = OrgContact.search(where: {location: {near: [@latitude, @longitude], within: "50km"}, org_person_id:nil},page: params[:page], per_page:20)
  		@org_contacts = @query.results # Assign results to @org_contacts

  		org_contacts_ids = Array.new # Make an empty id array
  		@org_contacts.each do |contact_id| # Loop through the query results
  			if !org_contacts_ids.include? contact_id.org_company_id # If the result id isn't in org_contacts_ids array
  				org_contacts_ids << contact_id.org_company_id # Throw it into the array
  			end
  		end
  		time_s = Time.now
  		@org_deliverers = OrgCompany.where(id:org_contacts_ids, typ_company_id: 2) # Grab company information from the array of org_contact_ids 
  		@deliverers = Array.new # Make a new deliverers array that'll house both org_company and org_contact info
  		@org_deliverers.each do |deliverer_info| # For each deliverer
  			# Grab the contact info from the array results of the search
  			@org_contacts.each do |deliverer_contact_info|
  				if deliverer_contact_info.org_company_id == deliverer_info.id
  					region = TypRegion.find_by_id(deliverer_contact_info.typ_region_id)
  					country = TypCountry.find_by_id(deliverer_contact_info.typ_country_id)
  					@deliverers << [deliverer_info, deliverer_contact_info, region, country] # Throw into the array an array of org_company and org_contact info
  				end
  			end
  		end
  		time_e = Time.now
  		puts (time_e - time_s)
	  	
	  	if @org_contacts.empty?
		  	flash.now[:danger] = 'There were no deliverers within your area. Please try again'
		end
	end

	# Called from list_deliverers as a asynchronous way to add deliverers to a company's preferred deliverers.
	def ajax_add_deliverers
		# Find the record if it exists, else create it.
		@deliverer = PreferredDeliverer.find_or_create_by(deliverer_id: params[:deliverer_id].to_i, supplier_id: current_org_person.org_company_id.to_i)
		if @deliverer.save # Try saving it...
			render json: @deliverer # Return a json object of @deliverer
		else # else there was an error and return the json error messages
			render json: {errors: @deliverer.errors.full_messages}
		end
	end

	# For the list of preferred deliverers in a profile
	def preferred_deliverers
		# Get all the deliverer_ids that are connected to this supplier
		s_time = Time.now
		@preferred_deliverers = get_preferred_deliverers
		e_time = Time.now
		puts (e_time - s_time)
	end

	# A button that removes a preferred deliverer from list of preferred deliverers
	def remove_preferred_deliverers
		pd = PreferredDeliverer.find_by(deliverer_id: params[:deliverer_id], supplier_id: current_org_person.org_company_id.to_i)
		pd.delete
		@preferred_deliverers = get_preferred_deliverers
		respond_to do |format|
			format.js
		end
	end

	private
		# Common function to get PreferredDeliverer information for company 
		# Used in preferred_deliverers and remove_preferred_deliverers
		def get_preferred_deliverers
			@deliverers = PreferredDeliverer.where(supplier_id: current_org_person.org_company_id.to_i).pluck(:deliverer_id)
			@deliverers_info = OrgCompany.where(id: @deliverers) # Find contact info of all the deliverers
			@deliverers_contact = OrgContact.where(org_company_id: @deliverers, org_person_id: nil)
			@preferred_deliverers = Array.new # Make a new deliverers array that'll house both org_company and org_contact info
			@deliverers_info.each do |deliverer_info|
				# Grab the contact info from the array results of the DB results
				@deliverers_contact.each do |deliverer_contact_info|
					if deliverer_contact_info.org_company_id == deliverer_info.id
						region = TypRegion.find_by_id(deliverer_contact_info.typ_region_id)
		  				country = TypCountry.find_by_id(deliverer_contact_info.typ_country_id)
		  				@preferred_deliverers << [deliverer_info, deliverer_contact_info, region, country] # Throw into the array an array of org_company and org_contact info
					end
				end
			end
			return @preferred_deliverers
		end

		# strong parameters. These are the parameters we allow.
		def company_register_params
			params.require(:org_company).permit(:name, :avatar, :description, :typ_fee_id, {typ_companies: :id}, org_contacts_attributes: [:address1, :address2,
	        :city, {typ_countries: :id}, {typ_regions: :id}, :postal_code, :email, 
	        :business_number, :cell_number])
		end

		# strong parameters. These are the parameters we allow.
		def company_edit_params
	      params.require(:org_company).permit(:name, :avatar, :description, org_contacts_attributes: [:address1, :address2,
	        :city, {typ_countries: :id}, {typ_regions: :id}, :postal_code, :email, 
	        :business_number, :cell_number])
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

		# Checks if the user is signed in, if they are skip this function, if not
		# redirect him to sign in page and save the last page they were on so
		# we can redirect him back to that page when he signs in.
		def signed_in_user
			unless signed_in?
				store_location
				redirect_to signin_url, flash: {warning: "Please sign in."}
			end
		end

		 # To see orders, products, company, the person should have a role in the company
	    def user_has_role_in_company?
	    	if current_org_person.typ_position_id.blank?
	    		redirect_to edit_org_person_path(current_org_person.id), flash: {warning: "You need to be approved by the company you have been assigned to first to access the requested page."}
	    	end
	    end

	    # Only COO, Director, and Regional Manager are allowed to edit company info
	    def allowed_to_edit_company_info?
	    	position = current_org_person.typ_position_id.to_i
	    	if position == 1 || position == 2 || position ==3
	    		true
	    	else 
	    		false
	    		redirect_to edit_org_person_path(current_org_person.id), flash: {warning: "Access is restricted for your role."}
	    	end
	    end
end
