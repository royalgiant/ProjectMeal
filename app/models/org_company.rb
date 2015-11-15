class OrgCompany < ActiveRecord::Base
	has_and_belongs_to_many :org_contacts
	has_many :org_persons
	has_many :org_products
	has_one :typ_fee
	belongs_to :typ_company, foreign_key: "typ_company_id"
	validates :typ_company, presence: true
	validates :name, presence: true
	accepts_nested_attributes_for :typ_company
	accepts_nested_attributes_for :org_contacts
	accepts_nested_attributes_for :typ_fee
	
	mount_uploader :avatar, AvatarUploader	
end