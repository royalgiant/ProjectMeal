class TypFee < ActiveRecord::Base
	has_many :TrxOrderFee
	validates :name, presence: true
	validates :fee_percentage, presence: true
end
