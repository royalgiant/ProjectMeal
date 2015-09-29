class CreateOrgPeople < ActiveRecord::Migration
  def change
    create_table :org_people do |t|
    	t.belongs_to :typ_position
    	t.belongs_to :org_company
    	t.string :first_name, null: false
    	t.string :last_name, null: false
    	t.string :stripe_publishable_key
    	t.string :stripe_secret_key
    	t.string :stripe_user_id
    	t.string :stripe_currency
    	t.string :stripe_account_type
    	t.text :stripe_account_status

      	t.timestamps
    end
  end
end