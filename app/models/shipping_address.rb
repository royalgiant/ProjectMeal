class ShippingAddress < ActiveRecord::Base
	belongs_to :trx_order, foreign_key: "trx_order_id"
	has_many :TrxOrderItem
	validates :first_name, presence: true
	validates :last_name, presence: true
	validates :address1, presence: true
	validates :city, presence: true
	validates :region, presence: true
	validates :postal_code, presence: true
	validates :country, presence: true
end