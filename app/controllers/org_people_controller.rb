class OrgPeopleController < ApplicationController
	before_action :signed_in_user, only: [:edit, :update, :stripe_settings]
  	before_action :correct_user,   only: [:edit, :update]

	def edit
		# All the setup that is needed to build the edit page view
		@person = OrgPerson.find(params[:id])
		@contactInfo = OrgContact.find_or_initialize_by(org_person_id: params[:id])
		@contactInfo[:email] = current_org_person.email
		@person.org_contacts.build(@contactInfo.attributes)
	end

	def update
		# Create org_ca to sanitize our hash to proper "contacts" attributes
		@org_ca = update_person_params["org_contacts_attributes"]["0"]
		@org_ca[:typ_country_id] = @org_ca.delete :typ_countries
		@org_ca[:typ_country_id] = @org_ca[:typ_country_id][:id]
		@org_ca[:typ_region_id] = @org_ca.delete :typ_regions
		@org_ca[:typ_region_id] = @org_ca[:typ_region_id][:id]
		@org_ca[:org_company_id] = @org_ca.delete :org_company
		@org_ca[:org_company_id] = @org_ca[:org_company_id][:id]
		    
		# Edit function variables, in case of failed validations and we re-render :edit
		@person = OrgPerson.find_by(id: current_org_person.id) #Find the OrgPerson corresponding to org_person_id FK
		# Using the org_person_id find/create the record and assing the attributes to @contactInfo
		@contactInfo = OrgContact.find_or_initialize_by(org_person_id: current_org_person.id).attributes
		@contactInfo[:email] = current_org_person.email
		@person.org_contacts.build(@contactInfo) #Build the form using @contactInfo
		if !@org_ca[:org_company_id].nil?
		    OrgPerson.update(current_org_person.id ,org_company_id: @org_ca[:org_company_id])
		end
		# Find contacts record or create them if necessary
		@contact = OrgContact.find_or_create_by(org_person_id: current_org_person.id)
		    
		# Try to save it, if it saves, then redirect to the edit page with success
		if @contact.update_attributes(@org_ca) 
		    # If this user also controls the information of the company (i.e. COO) then also update company email
		    OrgContact.where(email: current_org_person.email).update_all(email: @org_ca["email"]) 
		    # If there is a company, update the person record to reflect the company too.
		    flash[:success] = "Profile updated"
		    redirect_to edit_org_person_path(@person.id)
	    else # Failed. Re-render the page as unsucessful
	        render :edit
		end
	end

	# Edits a position/role (i.e. COO, Director, Store Manager, etc.)
	def edit_position
		person_info = OrgPerson.find_by_id(params[:id])
		person_info.update(typ_position_id: params[:typ_position_id], org_company_id: current_org_person.org_company_id)
	end
	# Removes a person from the company
	def remove_from_company
		person_info = OrgPerson.find_by_id(params[:id])
		person_info.update(typ_position_id: 0, org_company_id: nil)
		contact_info = OrgContact.find_by(org_person_id: params[:id])
		contact_info.update(org_company_id: nil)
	end

	# This connects the company to a bank account in their country, only accessible by the COO
	def stripe_settings
		@manager = StripeManaged.new(current_org_person)
		if !current_org_person.stripe_account_status.nil?
			@charges = [ 'Charges', current_org_person.stripe_account_status['charges_enabled'] ]
			@transfers = [ 'Transfers', current_org_person.stripe_account_status['transfers_enabled'] ]
			@dob = @manager.legal_entity.dob
			@date_selected = Date.new(@dob.year, @dob.month, @dob.day) rescue nil
		end
	end
	# This updates the necessary information required by stripe
	def stripe_update_settings
		manager = current_org_person.manager
		manager.update_account! params: params
		redirect_to org_people_stripe_settings_path
	end
	private 
		def update_person_params
			params.require(:org_person).permit(org_contacts_attributes: [:address1, :address2,
        	:city, {typ_countries: :id}, {typ_regions: :id}, {org_company: :id}, :postal_code, :email, 
        	:business_number, :cell_number, :org_person_id, :avatar])
		end

		# Before filters

	    def signed_in_user
	      unless signed_in?
	        store_location
	        redirect_to signin_url, flash: {warning: "Please sign in."}
	      end
	    end

	    # Checks to see if the current user is actually the user this page is suppose to show
    	# We don't want a person to type in the user of someone else in the link and edit their info
	    def correct_user
	      @user = OrgPerson.find_by_id(params[:id]) 
	      if !@user.nil? && (current_org_person.id == @user.id) #If user is found, go to edit page, else go to sign in
	      else
	        flash[:danger] = "The request cannot be fulfilled."
	        redirect_to(signin_path)
	      end
	    end
end
