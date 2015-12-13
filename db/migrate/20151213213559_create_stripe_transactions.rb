class CreateStripeTransactions < ActiveRecord::Migration
  def change
    create_table :stripe_transactions do |t|
    	t.belongs_to :trx_order
        t.string :txn_type
      	t.string :currency
      	t.decimal :total_amount, precision:20, scale: 4
      	t.decimal :tax_amount, precision:20, scale: 4
        t.text :notification_params
        t.string :txn_id
      	t.string :status
        t.string :description
      	t.timestamps null: false
    end
  end
end
