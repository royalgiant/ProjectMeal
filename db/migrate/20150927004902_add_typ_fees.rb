class AddTypFees < ActiveRecord::Migration
  def change
  	TypFee.create(name: "standard", fee_percentage: 0.05)
  	TypFee.create(name: "special", fee_percentage: 0.04)
  	TypFee.create(name: "discount", fee_percentage: 0.03)
  end
end
