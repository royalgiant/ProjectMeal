class Cart < ActiveRecord::Base
	has_one :org_person
	belongs_to :org_product
	validates :name, presence: true
	validates :price, presence: true, numericality: true
	validates :grocer, presence: true
	validates :quantity, presence: true, numericality: true
	validates :weight_in_grams, presence: true, numericality: true
	validates :expiry_date, presence: true
end
