class CreateTrxOrders < ActiveRecord::Migration
  def change
    create_table :trx_orders do |t|
    	  t.belongs_to :org_company
      	t.references :bill_to_contact
      	t.references :ship_to_contact
        t.references :trx_order_fee
        t.decimal :total_amount, precision:20, scale: 4
        t.datetime :purchased_at
        t.string :transport_method
      	t.timestamps
    end
  end
end
