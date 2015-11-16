$(document).ready(
	function() {
  		var subcategory;

  		$('.deleteFoodImage').hide();

	    if ($('.imagePhoto').length){
	    	$('.imagePreview').hide()
	    }

	 	$('.imagePhoto').click(function(){
	 		$('.imagePhoto').hide();
	 		$('.imagePreview').show().trigger('click');
	 	})
	    $('.imagePreview').click(function(){
		    $(this).attr('disabled', 'true');
		    $('#uploadImage').trigger('click');
		    $("#uploadImage").change(function(){
		        $('.imagePreview').removeAttr('disabled');
		        readURL(this);
		    });
		})

		$(".delivery_status").click(function(){
			var deliveryStatus = $(this).attr('deliveryStatus')
			var order_id = $(this).attr('orderId')
			var data = {
				delivery_status: deliveryStatus,
				trx_item_order_id: order_id
			}
			$(this).parents('li').slideUp("normal", function() { $(this).remove(); } );
			$.post('/org_products/delivery_status/', data);
		});

		$(".send_product_ready_email").click(function(){
			var order_id = $(this).attr('orderId')
			var data = {
				trx_item_order_id: order_id
			}
			$.post('/org_products/send_product_ready_email/', data);
		});

		function readURL(input) {
		    if (input.files && input.files[0]) {
		        var reader = new FileReader();
		        reader.onload = function (e) {
		            $('.imagePreview').css('background', 'url(' + e.target.result + ')');
		            $('.imageUpload, #uploadClick').hide();
		        }
		        $('.deleteFoodImage').show();
		        reader.readAsDataURL(input.files[0]);
		    }
		}

		$('.deleteFoodImage').click(function() {
			$('.deleteFoodImage').hide();
            $('#uploadImage').val('');
            $('.imagePreview').css('background', '');
            if ($('.imagePhoto').length){
            	$('.imagePhoto').show();
            	$('.imagePreview').hide()
            }else{
            	$('.imageUpload, #uploadClick').show();
            }
		});

		$('.org_products.new').ready(function() {
		    return $('li.sidebar_post_items_for_sale').addClass('active');
		});
  		$('.org_products.index, .org_products.edit').ready(function() {
    		return $('li.sidebar_posted_items').addClass('active');
  		});
  		$('.org_products.orders').ready(function() {
		    return $('li.sidebar_orders').addClass('active');
		});
		$('.org_products.completed_orders').ready(function() {
		    return $('li.sidebar_completed_orders').addClass('active');
		});
  		subcategory = $('#org_product_typ_subcategory_id').html();
	  	$('#org_product_typ_category_id').change(function() {
	    	var category, escaped_category, options;
	    	category = $('#org_product_typ_category_id :selected').text();
	    	escaped_category = category.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1');
	    	options = $(subcategory).filter("optgroup[label='" + escaped_category + "']").html();
	    	if (options) {
	      		$('#org_product_typ_subcategory_id').html(options).addClass('form-control');
	      		return $('#org_product_typ_subcategory_id').show();
	    	} else {
	      		$('#org_product_typ_subcategory_id').empty(options);
	      		return $('#org_product_typ_subcategory_id').hide(options);
	    	}
	  	});
  		return $('button.thumbup, button.thumbdown').click(function() {
    	var product_id, vote;
    	if ($(this).siblings('.thumbup').hasClass('voted')) {
      		$(this).siblings('.thumbup').removeClass('voted');
      		$(this).addClass('voted');
    	} else if ($(this).siblings('.thumbdown').hasClass('voted')) {
      		$(this).siblings('.thumbdown').removeClass('voted');
      		$(this).addClass('voted');
    	} else if ($(this).hasClass('voted')) {
      		$(this).removeClass('voted');
    	} else {
      		$(this).addClass('voted');
    	}
	    vote = $(this).find('span').attr('vote');
	    product_id = $(this).find('span').attr('id');
	    return $.ajax({
	      	url: "/org_products/vote_product",
	      	method: "POST",
	      	data: {
	        	id: product_id,
	        	vote: vote
	      	}
    	});
  	});
});
