class TypPosition < ActiveRecord::Base
	has_many :org_people
	validates :name, presence: true
end
