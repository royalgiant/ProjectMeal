class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
    	t.belongs_to :org_person
    	t.references :org_product
    	t.string :name, null: false
      t.float :tax_amount, default: 0
    	t.decimal :price, precision:5, scale: 2, null: false
    	t.string :grocer, null: false
    	t.integer :quantity, null: false
    	t.decimal :weight_in_grams, null: false
    	t.datetime :expiry_date, null: false
      t.timestamps null: false
    end
  end
end
