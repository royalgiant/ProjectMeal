class TypCountry < ActiveRecord::Base
	has_many :org_contact
	has_many :typ_region
end
