class OrgCompaniesController < ApplicationController

	def new
		signed_in_user #Be sure the user is signed in before he can create a company
		@company = OrgCompany.new # Make new company object 
		@contactInfo = OrgContact.new.attributes  # Make new contact object w/ empty attributes
		@company.org_contacts_build(@contactInfo)
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

end
