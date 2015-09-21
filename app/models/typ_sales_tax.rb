class TypSalesTax < ActiveRecord::Base
	belongs_to :typ_region, foreign_key: "typ_region_id"
	belongs_to :typ_tax, foreign_key: "typ_tax_id"
end
