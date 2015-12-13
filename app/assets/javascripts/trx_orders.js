// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready(function(){
	$('.trx_orders.list_purchases, .trx_orders.purchase_order').ready(function(){
		$('li.sidebar_purchases').addClass('active');
	});
	$('.trx_orders.list_personal_purchases').ready(function(){
		$('li.sidebar_personal_purchases').addClass('active');
	});

});