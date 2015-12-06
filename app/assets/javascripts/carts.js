$(document).ready(function(){
	$("div.delivery_options").click(function(){
		var deliveryMethod = $("input:radio[name='deliveryRadios']:checked").val()
		var data = {
			deliveryMode: deliveryMethod
		}
		$.post('/carts/add_delivery_method/', data);
	});
});