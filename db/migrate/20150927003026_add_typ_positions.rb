class AddTypPositions < ActiveRecord::Migration
  def up
  	TypPosition.create(name: "Chief of Operations");
  	TypPosition.create(name: "Director");
  	TypPosition.create(name: "Regional Manager");
  	TypPosition.create(name: "Store Manager");
  	TypPosition.create(name: "Employee");
  end

  def down
  end
end
