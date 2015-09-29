class AddTypTaxes < ActiveRecord::Migration
  def up
  	#Typ_taxes
  	TypTax.create(id: 1, name: "GST")
  	TypTax.create(id: 2, name: "PST")
  	TypTax.create(id: 3, name: "HST")
  	TypTax.create(id: 4, name: "QST")
  end
end
