class AddTypContacts < ActiveRecord::Migration
  def up
  	#Typ_contacts
  	TypContact.create(name: "Billing")
  	TypContact.create(name: "Shipping")
  end
end
