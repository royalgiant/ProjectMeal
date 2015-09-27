class AddTypCompanies < ActiveRecord::Migration
  def up
  	#Typ_companies
  	TypCompany.create(name: "Consumer")
  	TypCompany.create(name: "Deliverer")
  	TypCompany.create(name: "Supplier") 
  end
end
