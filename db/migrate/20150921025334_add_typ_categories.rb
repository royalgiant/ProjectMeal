class AddTypCategories < ActiveRecord::Migration
  def up
  	#Typ_categories
  	TypCategory.create(id: 1, name: "Bakery")
  	TypCategory.create(id: 2, name: "Deli")
  	TypCategory.create(id: 3, name: "Floral")
  	TypCategory.create(id: 4, name: "Grocery")
  	TypCategory.create(id: 5, name: "Meal Ideas")
  	TypCategory.create(id: 6, name: "Meat")
  	TypCategory.create(id: 7, name: "Organic")
  	TypCategory.create(id: 8, name: "Party Trays")
  	TypCategory.create(id: 9, name: "Produce")
  	TypCategory.create(id: 10, name: "Seafood")
  end
end
