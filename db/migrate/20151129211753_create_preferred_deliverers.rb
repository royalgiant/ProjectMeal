class CreatePreferredDeliverers < ActiveRecord::Migration
  def change
    create_table :preferred_deliverers do |t|
    	t.integer :deliverer_id, null: false
    	t.integer :supplier_id, null: false
    end
  end
end
