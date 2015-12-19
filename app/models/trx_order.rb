class TrxOrder < ActiveRecord::Base
	has_many :TrxOrderItem
	has_many :TrxOrderFee
	has_many :StripeTransaction
	belongs_to :bill_to_contact, class_name: 'OrgContact'
	belongs_to :ship_to_contact, class_name: 'ShippingAddress'
	serialize :notification_params

	private
end