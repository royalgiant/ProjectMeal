class TrxOrderItem < ActiveRecord::Base
	belongs_to :org_company, foreign_key: "org_company_id"
	belongs_to :TrxOrder, foreign_key: "trx_order_id"
	belongs_to :OrgProduct, foreign_key: "org_product_id"
	belongs_to :ShippingAddress, foreign_key: "shipping_address_id"
end
