class ProductReadyMailer < ApplicationMailer
	def send_product_ready_email(order, item)
		@order = order[:order]
	    @company = order[:company]
	  	@shipAddress = order[:shipAddress]
	  	@purchase_items = order[:purchase_items]
	  	@currency = order[:currency]
	  	@contact = order[:billed_contact]
	  	@item = item
	  	@total_tax = order[:total_tax]
	  	@pm_fee = order[:pm_fee]
	  	mail(to: @contact.email, subject: "ProjectMeal: An Item is Ready for Pickup for Purchase Order ##{order[:order].id}.") do |format|
	  		format.html
	  		format.text
	  		format.pdf do 
	  			attachments["invoice-#{order[:order].id}.pdf"] = WickedPdf.new.pdf_from_string(
	          		render_to_string(pdf: "invoice-#{@order.id}.pdf", template: "trx_orders/purchase_order.pdf.erb")
	        	)
	  		end
	  	end
	end
end
