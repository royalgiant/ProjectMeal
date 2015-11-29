class CreateShippingAddresses < ActiveRecord::Migration
  def change
    create_table :shipping_addresses do |t|
    	t.string :first_name, null: false
    	t.string :last_name, null: false
    	t.string :address1, null: false
    	t.string :address2
    	t.string :city, null: false
    	t.string :region, null: false
    	t.string :postal_code, null: false
    	t.string :country, null: false
    	t.string :telephone
    	t.string :email
        t.text :description
        t.belongs_to :trx_order
    	t.timestamps
    end
  end
end
