class OrgPeopleController < ApplicationController
	def edit
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

	private 
		def update_person_params
			params.require(:org_person).permit(org_contacts_attributes: [:address1, :address2,
        	:city, {typ_countries: :id}, {typ_regions: :id}, {org_company: :id}, :postal_code, :email, 
        	:business_number, :cell_number, :org_person_id, :avatar])
		end
end
