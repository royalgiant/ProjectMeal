class CreateTypContacts < ActiveRecord::Migration
  def change
    create_table :typ_contacts do |t|
    	t.string :name, null: false
      	t.timestamps null: false
    end
  end
end
