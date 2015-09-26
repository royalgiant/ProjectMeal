class OrgPerson < ActiveRecord::Base
	has_and_belongs_to_many :org_contacts
	belongs_to :org_company, foreign_key:"org_company_id"
	belongs_to :typ_position, foreign_key:"typ_position_id"
end
