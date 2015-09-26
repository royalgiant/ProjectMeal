class OrgContact < ActiveRecord::Base
	belongs_to :org_person, foreign_key: "org_person_id"
	belongs_to :org_company, foreign_key: "org_company_id"
	belongs_to :typ_contact, foreign_key: "typ_contact_id"
	belongs_to :typ_country, foreign_key: "typ_country_id"
	belongs_to :typ_region, foreign_key: "typ_region_id"
end
