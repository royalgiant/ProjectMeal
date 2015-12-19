class TypCompany < ActiveRecord::Base
	has_many :org_companies
	validates :name, presence: true
end
