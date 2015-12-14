class OrgPerson < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # , :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
	has_and_belongs_to_many :org_contacts
	belongs_to :org_company, foreign_key:"org_company_id"
	belongs_to :typ_position, foreign_key:"typ_position_id"
	validates :first_name, presence: true
	validates :last_name, presence: true
	serialize :stripe_account_status, JSON
	acts_as_voter
	accepts_nested_attributes_for :org_contacts

		# General 'has a Stripe account' check
		def connected?; !stripe_user_id.nil?; end

		# Stripe account type checks
		def managed?; stripe_account_type == 'managed'; end
		# def standalone?; stripe_account_type == 'standalone'; end
  		# def oauth?; stripe_account_type == 'oauth'; end

  		def manager
  			case stripe_account_type
    		when 'managed' then StripeManaged.new(self)
    		# when 'standalone' then StripeStandalone.new(self)
    		# when 'oauth' then StripeOauth.new(self)
    		end
  		end

  		def can_accept_charges
  			# return true if oauth?
    		return true if managed? && stripe_account_status['charges_enabled']
    		# return true if standalone? && stripe_account_status['charges_enabled']
    		return false
  		end
end
