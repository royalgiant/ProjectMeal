class AddTypPositions < ActiveRecord::Migration
  def up
  	# Typ_positions
    TypPosition.create(name: "Chief of Operations")
    TypPosition.create(name: "Director")
    TypPosition.create(name: "Regional Manager")
    TypPosition.create(name: "Store Manager") 
    TypPosition.create(name: "Employee") 
  end
end
