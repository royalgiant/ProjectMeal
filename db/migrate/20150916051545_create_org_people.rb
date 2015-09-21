class CreateOrgPeople < ActiveRecord::Migration
  def change
    create_table :org_people do |t|
    	t.belongs_to :typ_position
    	t.belongs_to :org_company
    	t.string :first_name, null: false
    	t.string :last_name, null: false
      	t.timestamps null: false
    end
  end
end
