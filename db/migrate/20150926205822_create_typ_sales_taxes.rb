class CreateTypSalesTaxes < ActiveRecord::Migration
  def change
    create_table :typ_sales_taxes do |t|
    	t.float :tax_rate, null: false
    	t.belongs_to :typ_region
    	t.belongs_to :typ_tax
    	t.timestamps
    end
  end
end
