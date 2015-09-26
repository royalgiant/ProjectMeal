class CreateOrgContactsOrgPeopleJoinTable < ActiveRecord::Migration
  def change
  	create_table :org_contacts_people do |t|
    	t.integer :org_person_id, null: false
      	t.integer :org_contact_id, null: false
      	t.timestamps 
    end
  end
end
