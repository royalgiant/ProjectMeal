class CartsController < ApplicationController

	def add
		# cart_item – try to find the item in the db if it exists
		if current_org_person
			cart_item = Cart.find_by(org_person_id: current_org_person.id, org_product_id: params[:product_id])
		end
		# It doesn't exist, and the user is logged on, create it for this user in the db.
		if cart_item.blank? && current_org_person
			cart_item = Cart.create(org_person_id: current_org_person.id,
									org_product_id: params[:product_id], 
									name: params[:title],
									tax_amount: params[:tax],
									price: params[:price], 
									grocer: params[:grocer],
									quantity: params[:quantity],
									weight_in_grams: params[:weight],
									expiry_date: params[:expiry])
		# It exists, and user is logged on, update it in the db.
		elsif cart_item && current_org_person
			cart_item.update(name: params[:title], 
							tax_amount: params[:tax],
							price: params[:price], 
							grocer: params[:grocer],
							quantity: params[:quantity],
							weight_in_grams: params[:weight],
							expiry_date: params[:expiry])
		# The user is not logged on, so we use sessions
		else
			session[:cart] ||={}
			session[:cart][params[:product_id]] = {id: params[:product_id],
												title: params[:title],
												tax_amount: params[:tax],
												price: params[:price], 
												grocer: params[:grocer],
												quantity: params[:quantity],
												weight: params[:weight],
												expiry: params[:expiry]

			}
		end
		render nothing:true
	end
end
