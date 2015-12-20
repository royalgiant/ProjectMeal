class InvoiceMailer < ApplicationMailer
	def invoice_details(details)
		@order = details[:order]
		@company = details[:company]
		@shipAddress = details[:shipAddress]
	  	@purchase_items = details[:purchase_items]
	    @notification_params_name = details[:notification_params]
	    @total_tax = details[:total_tax]
  		@currency = details[:currency]
	  	@contact = details[:billed_contact]
	  	@pm_fee = details[:pm_fee]

	  	mail(to: details[:billed_contact].email, subject: "ProjectMeal: Your Invoice for Purchase Order ##{details[:order].id}") do |format|
	  		format.html
	  		format.text
	  		format.pdf do 
	  			attachments["invoice-#{details[:order].id}.pdf"] = WickedPdf.new.pdf_from_string(
		          render_to_string(pdf: "invoice-#{@order.id}.pdf", template: "trx_orders/purchase_order.pdf.erb")
		        )
		    end
	  	end	
	end
end
