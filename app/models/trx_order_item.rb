class TrxOrderItem < ActiveRecord::Base
	belongs_to :org_company, foreign_key: "org_company_id"
	belongs_to :TrxOrder, foreign_key: "trx_order_id"
	belongs_to :OrgProduct, foreign_key: "org_product_id"
	belongs_to :ShippingAddress, foreign_key: "shipping_address_id"
	validates :name, presence: true
	validates :weight_in_grams, presence: true, numericality: true
	validates :available_quantity, presence: true, numericality: true
	validates :price, presence: true, numericality: true
	validates :expiry_date, presence: true, date: true
	validates :typ_category_id, presence: true, numericality: true
	validates :typ_subcategory_id, presence: true, numericality: true
end