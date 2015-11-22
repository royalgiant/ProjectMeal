class TrxOrderFee < ActiveRecord::Base
	belongs_to :TrxOrder, foreign_key: "trx_order_id"
	validates :fee_amount, presence: true, numericality: true
end
