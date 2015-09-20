class OrgProduct < ActiveRecord::Base
	belongs_to :org_company, foreign_key: "org_company_id"
	belongs_to :typ_category, foreign_key: "typ_category_id"
	belongs_to :typ_subcategory, foreign_key: "typ_subcategory_id"
end
