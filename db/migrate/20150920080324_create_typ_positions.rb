class CreateTypPositions < ActiveRecord::Migration
  def change
    create_table :typ_positions do |t|
    	t.string :name, null: false
      	t.timestamps null: false
    end
  end
end
