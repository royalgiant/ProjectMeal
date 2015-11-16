$(document).ready(function(){
	$("input.expiry_field").removeAttr("type");
	$("input.expiry_field").focusin(function(){
		$("input.expiry_field").attr("type", "date")
	});
	$("input.expiry_field").focusout(function(){
		$("input.expiry_field").removeAttr("type");
	});
});