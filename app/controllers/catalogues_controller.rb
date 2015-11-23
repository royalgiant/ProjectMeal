class CataloguesController < ApplicationController
	def index
		# If search is not empty
		if (current_org_person && @contact = OrgContact.find_by(org_person_id: current_org_person.id))
			@country = TypCountry.find_by_id(@contact['typ_country_id'])
			@currency = Money.new(1, @country.currency_code).currency
			session[:currency] = @currency
			@latitude = @contact["latitude"]
			@longitude = @contact["longitude"]
		else
			# If the user had visited before and have geolocation saved in their cookies, use that
			if !cookies[:geolocation].nil?
				@location = JSON.parse(cookies[:gelocation]).symbolize_keys
			else
				# Geolocate the user by IP address and use the default currency
				@ip = request.remote_ip
				if Rails.env.production?
					locale = request.location
					@location = {longitude: locale.longitude, latitude: locale.latitude, country_code: local.country_code}
				else
					@location = GeoIp.geolocation("24.84.225.124")
				end

				@longitude = @location[:longitude]
				@latitude = @location[:latitude]
				@country_code = @location[:country_code]
				@country = TypCountry.find_by_iso(@country_code)
				@currency = @Money.new(1, @country.currency_code).currency
				session[:currency] = @currency
				cookies[:geolocation] = {value: JSON.generate(@location), expires: Time.now + 3600 * 24 * 7} #Set cookie for a week
				# If you get an undefined data error, chances are, the internet is too slow
      			# Change the timeout in geocoder.rb to more than 240 secs    
			end	
		end
		if params[:search]
			
		else
			@org_product = {} # Search was empty. Give nothing.
		end
	end
end
