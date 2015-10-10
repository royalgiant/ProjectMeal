class OrgPerson < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # , :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
	has_and_belongs_to_many :org_contacts
	belongs_to :org_company, foreign_key:"org_company_id"
	belongs_to :typ_position, foreign_key:"typ_position_id"
	accepts_nested_attributes_for :org_contacts
end
