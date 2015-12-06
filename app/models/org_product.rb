class OrgProduct < ActiveRecord::Base
	belongs_to :org_company, foreign_key: "org_company_id"
	belongs_to :typ_category, foreign_key: "typ_category_id"
	belongs_to :typ_subcategory, foreign_key: "typ_subcategory_id"
	validates :typ_category, presence: true
	validates :typ_subcategory, presence: true
	validates :name, presence: true
	validates :weight_in_grams, numericality: true
	validates :price, presence: true, numericality: true
	validates :available_quantity, presence: true, numericality: { only_integer: true}
	validates :expiry_date, presence: true
	validates_inclusion_of :online_order_available, in: [true,false] 
	mount_uploader :image, ImageUploader
	searchkick locations: ["location"]
	acts_as_votable
	def search_data
		attributes.merge(
			location: [latitude, longitude],
			org_company_name: org_company(&:name)
		) 
	end
end