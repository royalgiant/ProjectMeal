class TrxOrder < ActiveRecord::Base
	has_many :TrxOrderItem
	has_many :TrxOrderFee
end
