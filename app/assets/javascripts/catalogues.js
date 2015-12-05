$(document).ready(function(){
	$(".addedPopup").click(function(){
		// This block of code is literally for finding the values and inserting them into variables
		var productId, title, price, grocer, qty, available_qty, wig, expiry;
		productId = $(this).parents("div.quantity-box").siblings("div#prodInfo").find("span input#id").val();
		tax = $(this).parents("div.quantity-box").siblings("div#prodInfo").find("span input#tax").val();
		title = $(this).parents("div.quantity-box").siblings("div#prodInfo").children("h4#title").text();
		price = $(this).parents("div.quantity-box").siblings("div#prodInfo").children("div.price").children("span").text();
		grocer = $(this).parents("div.quantity-box").siblings("div#prodInfo").children("div.grocer").children("span").text();
		qty = $(this).parent().siblings("input#quantity").val();
		available_qty =  $(this).parents("div.quantity-box").siblings("div#prodInfo").children("div#aq").children("span").text();
		wig = $(this).parents("div.quantity-box").siblings("div#prodInfo").children("div#wig").children("span").text();
		expiry = $(this).parents("div.quantity-box").siblings("div#prodInfo").children("div.expiry").children("i").text();
		

		var data = {
			product_id: productId,
			tax: tax,
			title: title,
			price: price,
			grocer: grocer,
			quantity: qty,
			available_quantity: available_qty, 
			weight: wig,
			expiry: expiry
		};

		// If statement handles the customizing of messages based on user actions
		// If there are 0 or null entered for quantity, change title to "Enter quantity" and message to "Please input a number for quantity"
		if(parseInt(qty) > parseInt(available_qty)){
			$(this).parents("div.quantity-box").children("div.addProdModal").find("h4.modal-title").text("Not enough available quantity!");
			message = "There is not enough available quantity from the grocer to fulfill your order.";
			$(this).parents("div.quantity-box").children("div.addProdModal").find("p#modal-message").text(message);
		}
		else if (isNaN(qty)){
			$(this).parents("div.quantity-box").children("div.addProdModal").find("h4.modal-title").text("Please enter a number!");
			message = "A quantity is expected, please enter a number.";
			$(this).parents("div.quantity-box").children("div.addProdModal").find("p#modal-message").text(message);		
		} 
		else{
			if(parseInt(qty) === 0 || qty === ""){
				$(this).parents("div.quantity-box").children("div.addProdModal").find("h4.modal-title").text("Enter a quantity");
				message = "Please input a number for quantity.";
				$(this).parents("div.quantity-box").children("div.addProdModal").find("p#modal-message").text(message);
			}	
			// Message is amount of an item added to cart. Title is success.	
			else if (parseInt(qty) === 1){
				message = "There is now "+qty+" "+title+" in your cart.";
				$(this).parents("div.quantity-box").children("div.addProdModal").find("h4.modal-title").text("Success! Added "+title+" to cart.");
				$(this).parents("div.quantity-box").children("div.addProdModal").find("p#modal-message").text(message);	
				$.post('/carts/add/', data);
			}
			// Message is amount of an item added to cart. Title is success.	
			else{
				message = "There are now "+qty+" "+title+" in your cart.";
				$(this).parents("div.quantity-box").children("div.addProdModal").find("h4.modal-title").text("Success! Added "+title+" to cart.");
				$(this).parents("div.quantity-box").children("div.addProdModal").find("p#modal-message").text(message);
				$.post('/carts/add/', data);
			}
		}			
	});
});
	

	
	
			 
		
		
