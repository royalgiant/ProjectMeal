class TypTax < ActiveRecord::Base
	has_many :typ_sales_taxes
	validates :name, presence: true
end
