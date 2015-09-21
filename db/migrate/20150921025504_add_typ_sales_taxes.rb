class AddTypSalesTaxes < ActiveRecord::Migration
  def up
  	#Typ_sales_taxes
  	TypSalesTax.create(tax_rate: 5, typ_region_id: 526, typ_tax_id: 1)
  	TypSalesTax.create(tax_rate: 5, typ_region_id: 527, typ_tax_id: 1)
  	TypSalesTax.create(tax_rate: 7, typ_region_id: 527, typ_tax_id: 2)
  	TypSalesTax.create(tax_rate: 5, typ_region_id: 528, typ_tax_id: 1)
  	TypSalesTax.create(tax_rate: 8, typ_region_id: 528, typ_tax_id: 2)
  	TypSalesTax.create(tax_rate: 13, typ_region_id: 529, typ_tax_id: 3)
  	TypSalesTax.create(tax_rate: 13, typ_region_id: 530, typ_tax_id: 3)
  	TypSalesTax.create(tax_rate: 5, typ_region_id: 537, typ_tax_id: 3)
  	TypSalesTax.create(tax_rate: 15, typ_region_id: 531, typ_tax_id: 3)
  	TypSalesTax.create(tax_rate: 5, typ_region_id: 538, typ_tax_id: 1)
  	TypSalesTax.create(tax_rate: 13, typ_region_id: 532, typ_tax_id: 3)
  	TypSalesTax.create(tax_rate: 14, typ_region_id: 533, typ_tax_id: 3)
  	TypSalesTax.create(tax_rate: 5, typ_region_id: 534, typ_tax_id: 1)
  	TypSalesTax.create(tax_rate: 9.975, typ_region_id: 534, typ_tax_id: 2)
  	TypSalesTax.create(tax_rate: 5, typ_region_id: 535, typ_tax_id: 1)
  	TypSalesTax.create(tax_rate: 5, typ_region_id: 535, typ_tax_id: 2)
  	TypSalesTax.create(tax_rate: 5, typ_region_id: 536, typ_tax_id: 1)
  end
end
