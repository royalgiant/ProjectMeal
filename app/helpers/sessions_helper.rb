module SessionsHelper

	def signed_in?
		!current_org_person.nil?
	end

	def redirect_back_or(default)
		redirect_to(session[:return_to] || default)
		session.delete(:return_to)
	end

	def store_location
		session[:return_to] = request.url if request.get?
	end

	# Gets the company_typ that the user is associated with.
	def company_typ
	   company_typ = OrgCompany.where(id: current_org_person.org_company_id)
	   @company_typ = company_typ[0]
	end

end