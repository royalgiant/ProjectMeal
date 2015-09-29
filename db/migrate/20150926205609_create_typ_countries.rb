class CreateTypCountries < ActiveRecord::Migration
  def change
    create_table :typ_countries do |t|
      	t.string :iso
    	  t.string :iso3
    	  t.string :fips
    	  t.string :country
      	t.string :continent
      	t.string :currency_code
      	t.string :currency_name
      	t.string :phone_prefix
      	t.string :postal_code
      	t.string :languages
      	t.string :geonameid
    end
  end
end
