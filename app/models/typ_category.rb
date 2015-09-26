class TypCategory < ActiveRecord::Base
	has_many :org_products
	has_many :typ_subcategory
end
