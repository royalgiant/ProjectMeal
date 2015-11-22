class TypContact < ActiveRecord::Base
	has_many :org_contacts
	validates :name, presence: true
end
