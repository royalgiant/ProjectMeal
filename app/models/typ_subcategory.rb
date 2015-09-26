class TypSubcategory < ActiveRecord::Base
	belongs_to :typ_category, foreign_key: "typ_category_id"
	has_many :org_products
end
