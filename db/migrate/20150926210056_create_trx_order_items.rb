class CreateTrxOrderItems < ActiveRecord::Migration
  def change
    create_table :trx_order_items do |t|
    	t.string :name, null: false
    	t.text :description, null: false
    	t.decimal :weight_in_grams, null: false
    	t.decimal :price, precision:20, scale: 4, null: false
    	t.decimal :available_quantity, null: false
        t.integer :quantity, null: false
    	t.datetime :expiry_date, null: false
    	t.string :image, null: false
    	t.belongs_to :org_company
        t.belongs_to :org_product
        t.belongs_to :typ_category
        t.belongs_to :typ_subcategory
    	t.belongs_to :trx_order
        t.belongs_to :shipping_address
        t.decimal :net_amount, precision:20, scale: 4
      	t.decimal :tax_amount, precision:20, scale: 4
        t.string :description
        t.boolean :delivery_status
        t.timestamps
    end
  end
end
