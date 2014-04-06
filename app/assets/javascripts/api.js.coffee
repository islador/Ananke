# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
	#Function to detect clicks on the in table whitelist entity "Delete" button.
	$("#enroll_new_api").click ->
		#Extract necessary data for AJAX from the page.
		target = $("#" + this.id).attr("data-target-path")
		keyID = $("#key_id").val()
		vCode = $("#v_code").val()
		main_checked = $("#main_api").prop('checked')
		authenticity_token = $('meta[name=csrf-token]').attr("content")

		$.ajax({
			#A post with a method data attribute is used to preserve cross browser compability.
			url: target, type: "POST",
			data: {authenticity_token: authenticity_token, key_id: keyID, v_code: vCode},
			#On success, return code 200, trigger the entity_name field
			done: clear_text_field("#key_id"),
			done: clear_text_field("#v_code")
		})


#Function to set any text field's value to zero
	clear_text_field = (id) ->
		#alert id
		$(id).val("")