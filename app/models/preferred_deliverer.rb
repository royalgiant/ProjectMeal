class PreferredDeliverer < ActiveRecord::Base
	validates :deliverer_id, presence: true, numericality: true
	validates :supplier_id, presence: true, numericality: true
end