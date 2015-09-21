class TrxOrderFee < ActiveRecord::Base
	belongs_to :TrxOrder, foreign_key: "trx_order_id"
end
