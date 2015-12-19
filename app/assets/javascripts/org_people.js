var setupFieldsNeeded, setupManaged;
$(document).ready(function() {
  var regions;

  $('.deletePhoto').hide();

  if ($('.profilePhoto').length){
  	$('.photoPreview').hide()
  }

 	$('.profilePhoto').click(function(){
 		$('.profilePhoto').hide();
 		$('.photoPreview').show().trigger('click');
 	})
    $('.photoPreview').click(function(){
	    $(this).attr('disabled', 'true');
	    $('#uploadAvatar').trigger('click');
	    $("#uploadAvatar").change(function(){
	        $('.photoPreview').removeAttr('disabled');
	        readURL(this);
	    });
	})

	function readURL(input) {
	    if (input.files && input.files[0]) {
	        var reader = new FileReader();
	        reader.onload = function (e) {
	            $('.photoPreview').css('background', 'url(' + e.target.result + ')');
	            $('.photoUpload, #uploadClick').hide();
	        }
	        $('.deletePhoto').show();
	        reader.readAsDataURL(input.files[0]);
	    }
	}

	$('.deletePhoto').click(function() {
		$('.deletePhoto').hide();
        $('#uploadAvatar').val('');
        $('.photoPreview').css('background', '');
        if ($('.profilePhoto').length){
        	$('.profilePhoto').show();
        	$('.photoPreview').hide()
        }else{
        	$('.photoUpload, #uploadClick').show();
        }
	});

    $('.org_people.edit').ready(function() {
        return $('li.sidebar_overview').addClass('active');
    });
    $('.org_people.stripe_settings').ready(function() {
        $('li.sidebar_stripe_settings').addClass('active');
        // Stripe Connect code
	    setupManaged() //pre-connection
	    setupFieldsNeeded(); // Connected user, but we need info
    });
    regions = $('#org_person_org_contacts_attributes_0_typ_regions_id').html();
    $('#org_person_org_contacts_attributes_0_typ_countries_id').change(function() {
	    var country, escaped_country, options;
	    country = $('#org_person_org_contacts_attributes_0_typ_countries_id :selected').text();
	    escaped_country = country.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1');
	    options = $(regions).filter("optgroup[label='" + escaped_country + "']").html();
	    if (options) {
	        $('#org_person_org_contacts_attributes_0_typ_regions_id').html(options).addClass('form-control');
	        return $('#org_person_org_contacts_attributes_0_typ_regions_id').show();
	    } else {
	        $('#org_person_org_contacts_attributes_0_typ_regions_id').empty(options);
	        return $('#org_person_org_contacts_attributes_0_typ_regions_id').hide(options);
	    }
	});
});

setupManaged = function() {
	var container, countrySelect, createButton, form, tosEl;
  	container = $('#stripe-managed');
	if (container.length === 0) {
	    return;
	}
  	tosEl = container.find('.tos input');
  	countrySelect = container.find('.country');
  	form = container.find('form');
  	createButton = form.find('.btn');
  	tosEl.change(function() {
    	return createButton.toggleClass('disabled', !tosEl.is(':checked'));
  	});
  	form.submit(function(e) {
    	if (!tosEl.is(':checked')) {
      	e.preventDefault();
      	return false;
    }
    	return createButton.addClass('disabled').val('...');
  	});
  	return countrySelect.change(function() {
    	var termsUrl;
    	termsUrl = "https://stripe.com/" + (countrySelect.val().toLowerCase()) + "/terms";
    	return tosEl.siblings('a').attr({
      		href: termsUrl
    	});
  	});
};

setupFieldsNeeded = function() {
  	var container, form;
  	container = $('.needed');
  	if (container.length === 0) {
    	return;
  	}
  	form = container.find('form');
  	return form.submit(function(e) {
    	var baContainer, button, tokenField;
    	button = form.find('.buttons .btn');
    	button.addClass('disabled').val('Saving...');
    	if ((baContainer = form.find('#bank-account')).length > 0) {
      		Stripe.setPublishableKey(baContainer.data('publishable'));
      		tokenField = form.find('#bank_account_token');
	      	if (tokenField.is(':empty')) {
	        	e.preventDefault();
	        	Stripe.bankAccount.createToken(form, function(_, resp) {
	          	if (resp.error) {
	            	button.removeClass('disabled').val('Save Info');
	            	return alert(resp.error.message);
	          	} else {
	            	tokenField.val(resp.id);
	            	return form.get(0).submit();
	          	}
	        });
        	return false;
      		}
    	}
  	});
};