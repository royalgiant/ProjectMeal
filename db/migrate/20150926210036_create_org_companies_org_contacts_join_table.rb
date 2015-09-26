class CreateOrgCompaniesOrgContactsJoinTable < ActiveRecord::Migration
  def change
  	create_table :org_companies_contacts do |t|
  		t.integer :org_company_id, null: false
    	t.integer :org_contact_id, null: false
  	end
  end
end
