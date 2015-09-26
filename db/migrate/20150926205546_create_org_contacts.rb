class CreateOrgContacts < ActiveRecord::Migration
  def change
    create_table :org_contacts do |t|
    	t.string :address1, null: false
    	t.string :address2
    	t.string :city, null: false
    	t.string :postal_code, null: false
    	t.string :email, null: false
    	t.string :business_number, null: false
    	t.string :cell_number
        t.float :latitude, null: false
        t.float :longitude, null: false
        t.string :avatar
    	t.belongs_to :typ_contact
    	t.belongs_to :typ_country
    	t.belongs_to :typ_region
        t.belongs_to :org_company
        t.belongs_to :org_person
      	t.timestamps
    end
  end
end
