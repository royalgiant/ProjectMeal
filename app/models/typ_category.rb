class TypCategory < ActiveRecord::Base
	validates :name, presence: true
	has_many :org_products
	has_many :typ_subcategory
end
